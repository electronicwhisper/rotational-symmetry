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
    @model.objects.push(center)

    centerRef = new Ref(new Ref.Path([{wreath: @model, op: 0}]), center)
    rotation = new Model.RotationWreath(centerRef, 12)
    @model.objects.push(rotation)

    @contextWreath = rotation


  # ===========================================================================
  # Layer Manager
  # ===========================================================================

  setupLayerManager: ->
    @layerManager = new LayerManager()


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

    else if toolName == "Point"
      canvas.drawPoint(new Geo.Point(0, 0))

    else if toolName == "LineSegment"
      p1 = new Geo.Point(-10, -10)
      p2 = new Geo.Point(10, 10)
      l = new Geo.Line(p1, p2)
      canvas.drawPoint(p1)
      canvas.drawPoint(p2)
      canvas.drawLine(l)

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
    @draw()

  workspacePosition: (e) ->
    pointerPosition = new Geo.Point(e.clientX, e.clientY)
    return workspacePosition = @canvas.browserToWorkspace(pointerPosition)

  canvasPointerDown: (e) =>
    e.preventDefault()
    @tool.pointerDown(e)
    @draw()

  canvasPointerMove: (e) =>
    @tool.pointerMove(e)
    @draw()

  canvasPointerUp: (e) =>
    @tool.pointerUp(e)
    @draw()

  canvasPointerLeave: (e) =>
    @tool.pointerLeave(e)
    @draw()


  draw: ->
    # @canvas.clear()
    # # @canvas.drawAxes()

    # refs = @model.refs()
    # for ref in refs
    #   object = ref.evaluate()
    #   @canvas.drawObject(object)
    Render.render(@canvas, this)

    @layerManager.writeModelToDOM(@model)


  refsNearPointer: (e) ->
    pointerPosition = new Geo.Point(e.clientX, e.clientY)
    canvasPosition = @canvas.browserToCanvas(pointerPosition)

    result = []
    refs = @model.refs()
    for ref in refs
      object = ref.evaluate()
      isNear = @canvas.isObjectNearPoint(object, canvasPosition)
      if isNear
        result.push(ref)
    return result


  mergePointRefs: (destinationRef, sourceRef) ->


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



