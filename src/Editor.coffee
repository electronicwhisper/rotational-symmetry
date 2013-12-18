class Editor
  constructor: ->
    @tool = new EditorTool.Select(this)
    @contextWreath = null

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
    @tool.pointerMove(e)
    @refresh()

  canvasPointerUp: (e) =>
    @tool.pointerUp(e)
    @refresh()

  canvasPointerLeave: (e) =>
    @tool.pointerLeave(e)
    @refresh()


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



  mergePointRefs: (pointRefs...) ->
    pointLocation = pointRefs[0].evaluate()
    mergedPoint = new Model.Point(pointLocation)

    objects = []
    findObjects = (object) ->
      objects.push(object)
      for childObject in object.children
        findObjects(object)
    findObjects(@model)

    for object in objects
      modelPointRefs = object.points()

      for modelPointRef in modelPointRefs
        matchesPointRef = _.find pointRefs, (pointRef) ->
          pointRef.object == modelPointRef.object
        if matchesPointRef
          # Need to mutate modelPointRef
          steps = matchesPointRef.path.steps
          steps = steps.slice().reverse()
          steps = _.map steps, (step) ->
            {
              wreath: step.wreath
              op: step.wreath.inverse(step.op)
            }
          modelPointRef.object = mergedPoint
          modelPointRef.path = new Ref.Path(steps)


  removeObject: (object) ->
    removeObjectFromWreath = (object, wreath) ->
      wreath.objects = _.without(wreath.objects, object)
      # Recurse
      for child in wreath.objects
        if child instanceof Model.Wreath
          removeObjectFromWreath(object, child)
    removeObjectFromWreath(object, @model)

  movePointRef: (pointRef, workspacePosition) ->




