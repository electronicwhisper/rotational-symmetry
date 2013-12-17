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
    @model = new Model.IdentityWreath()
    center = new Model.Point(new Geo.Point(0, 0))
    # @model.objects.push(center)

    centerRef = new Ref(new Ref.Path([{wreath: @model, op: 0}]), center)
    rotation = new Model.RotationWreath(centerRef, 12)
    @model.objects.push(rotation)

    @contextWreath = rotation


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


  mergePointRefs: (pointRefs...) ->
    point = pointRefs[0].evaluate
    # Iterate through model. Any Ref to a Model.Point equal to one of the pointRefs' objects needs to change.

  removeObject: (object) ->
    removeObjectFromWreath = (object, wreath) ->
      wreath.objects = _.without(wreath.objects, object)
      # Recurse
      for child in wreath.objects
        if child instanceof Model.Wreath
          removeObjectFromWreath(object, child)
    removeObjectFromWreath(object, @model)

  movePointRef: (pointRef, workspacePosition) ->

  findSnapRef: (e, excludePoints=[]) ->
    snapRefs = @refsNearPointer(e)
    snapRefs = _.reject snapRefs, (snapRef) =>
      _.contains(excludePoints, snapRef.object)
    if snapRefs.length > 0
      return snapRefs[0]
    else
      return null


