class Editor
  constructor: ->
    @tool = new EditorTool.Select(this)
    @contextWreath = null
    @movingPointRef = null

    @setupModel()
    @setupLayerManager()
    @setupPalette()
    @setupCanvas()


  # ===========================================================================
  # Model
  # ===========================================================================

  setupModel: ->
    @model = new Model.Wreath()
    center = new Model.Point(new Geo.Point(0, 0))
    # @model.objects.push(center)

    centerRef = new Ref(new Ref.Path([{wreath: @model, op: 0}]), center)
    rotation = new Model.RotationWreath(centerRef, 12)
    @model.objects.push(rotation)

    @contextWreath = rotation

    window.model = @model


  # ===========================================================================
  # Layer Manager
  # ===========================================================================

  setupLayerManager: ->
    @layerManager = new LayerManager(this)


  # ===========================================================================
  # Palette
  # ===========================================================================

  setupPalette: ->
    palette = document.querySelector("#palette")
    for toolEl in palette.querySelectorAll(".palette-tool")
      toolName = toolEl.getAttribute("data-tool")
      canvasEl = toolEl.querySelector("canvas")
      @drawPaletteTool(toolName, canvasEl)

    palette.addEventListener("pointerdown", @palettePointerDown)

  drawPaletteTool: (toolName, canvasEl) ->
    canvas = new Canvas(canvasEl)
    if toolName == "Select"

    else if toolName == "LineSegment"
      p1 = new Geo.Point(-10, -10)
      p2 = new Geo.Point(10, 10)
      Render.drawPoint(canvas, p1)
      Render.drawPoint(canvas, p2)
      Render.drawLine(canvas, p1, p2)

    else if toolName == "RotationWreath"
      p1 = new Geo.Point(0, 0)
      Render.drawRotationWreath(canvas, p1, 12)

  palettePointerDown: (e) =>
    toolEl = e.target.closest(".palette-tool")
    return unless toolEl?
    toolName = toolEl.getAttribute("data-tool")
    @selectTool(toolName)

  selectTool: (toolName) ->
    @tool = new EditorTool[toolName](this)
    palette = document.querySelector("#palette")
    for toolEl in palette.querySelectorAll(".palette-tool")
      toolEl.removeAttribute("data-selected")
    toolEl = palette.querySelector(".palette-tool[data-tool='#{toolName}']")
    toolEl.setAttribute("data-selected", "")


  # ===========================================================================
  # Canvas
  # ===========================================================================

  setupCanvas: ->
    canvasEl = document.getElementById("c")
    @canvas = new Canvas(canvasEl)

    window.addEventListener("resize", @resize)
    @resize()

    canvasEl.addEventListener("pointerdown", @canvasPointerDown)
    canvasEl.addEventListener("pointermove", @canvasPointerMove)
    canvasEl.addEventListener("pointerup", @canvasPointerUp)
    canvasEl.addEventListener("pointerleave", @canvasPointerLeave)
    canvasEl.addEventListener("pointercancel", @canvasPointerLeave)

  resize: =>
    @canvas.setupSize()
    @refresh()

  workspacePosition: (e) ->
    pointerPosition = new Geo.Point(e.clientX, e.clientY)
    return workspacePosition = @canvas.browserToWorkspace(pointerPosition)

  canvasPointerDown: (e) =>
    e.preventDefault()
    @tool.pointerDown(e)
    @refresh()

  canvasPointerMove: (e) =>
    @doMove(e)

    @tool.pointerMove(e)
    @refresh()

  canvasPointerUp: (e) =>
    @doMove(e, true)
    @endMove()

    @tool.pointerUp(e)
    @refresh()

  canvasPointerLeave: (e) =>
    @tool.pointerLeave(e)
    @refresh()


  startMove: (e, pointRef) ->
    if !pointRef
      point = new Model.Point(new Geo.Point(0, 0))
      path = new Ref.Path([])
      pointRef = new Ref(path, point)
    @movingPointRef = pointRef
    @doMove(e)
    return pointRef

  doMove: (e, shouldMerge=false) ->
    if @movingPointRef
      snapRef = @findSnapRef(e, [@movingPointRef.object])
      if snapRef
        if shouldMerge
          @mergePointRefs(snapRef, @movingPointRef)
        else
          moveToPoint = snapRef.evaluate()
          @movingPointRef.object.point = @movingPointRef.path.globalToLocal(moveToPoint)
      else
        moveToPoint = @workspacePosition(e)
        @movingPointRef.object.point = @movingPointRef.path.globalToLocal(moveToPoint)

  endMove: ->
    @movingPointRef = null


  refresh: ->
    Render.render(@canvas, this)

    @layerManager.writeToDOM()


  refsNearPointer: (e) ->
    pointerPosition = new Geo.Point(e.clientX, e.clientY)
    canvasPosition = @canvas.browserToCanvas(pointerPosition)

    result = []
    pointRefs = @model.pointRefs()
    for pointRef in pointRefs
      point = pointRef.evaluate()
      isNear = @canvas.isObjectNearPoint(point, canvasPosition)
      if isNear
        result.push(pointRef)
    return result


  findSnapRef: (e, excludePoints=[]) ->
    snapRefs = @refsNearPointer(e)
    snapRefs = _.reject snapRefs, (snapRef) =>
      _.contains(excludePoints, snapRef.object)
    if snapRefs.length > 0
      return snapRefs[0]
    else
      return null




  mergePointRefs: (anchorPointRef, pointRefToMerge) ->
    # TODO: There's still a bug in that you shouldn't be allowed to merge a
    # point onto a point that it "depends" on. E.g. You shouldn't be able to
    # merge the center of a rotation wreath onto a point that is affected by
    # the rotation wreath. You never want to end up with a pointRef which has
    # in its path the point itself.

    # TODO: With dragging you can sometimes end up dragging the pointRef
    # "further" down the tree, rather than the one closest. E.g. If you drag a
    # point to its rotation wreath's center, and then drag the center, you
    # should drag the center, not the point...

    objectToMerge = pointRefToMerge.object
    pathToAppend = pointRefToMerge.path.inverse().append(anchorPointRef.path)

    # TODO: This finding all descendant objects should be a method on the model
    objects = []
    findObjects = (object) ->
      objects.push(object)
      for childObject in object.children()
        findObjects(childObject)
    findObjects(@model)

    for object in objects
      modelPointRefs = object.points()
      modelPointRefs = _.without(modelPointRefs, null)
      for modelPointRef in modelPointRefs
        if modelPointRef.object == objectToMerge
          # TODO: This is a mutation of modelPointRef, but cleaner would be to
          # mutate object (maybe make this a method on a Model, to mutate its
          # points so as to create a merge.)
          modelPointRef.object = anchorPointRef.object
          modelPointRef.path = modelPointRef.path.append(pathToAppend)


  removeObject: (object) ->
    removeObjectFromWreath = (object, wreath) ->
      wreath.objects = _.without(wreath.objects, object)
      # Recurse
      for child in wreath.objects
        if child instanceof Model.Wreath
          removeObjectFromWreath(object, child)
    removeObjectFromWreath(object, @model)

  movePointRef: (pointRef, workspacePosition) ->




