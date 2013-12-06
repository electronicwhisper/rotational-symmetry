class Editor
  constructor: ->
    @tool = "select"
    @context = null
    @moving = null

    @setupModel()
    @setupPalette()
    @setupCanvas()


  # ===========================================================================
  # Model
  # ===========================================================================

  setupModel: ->
    center = new Model.Point(new Geo.Point(0, 0))
    centerAddress = new Model.Address(new Model.Path(), center)
    @model = new Model.RotationWreath(centerAddress, 9)
    @context = @model


  # ===========================================================================
  # Palette
  # ===========================================================================

  setupPalette: ->
    palette = document.querySelector("#palette")
    for toolEl in palette.querySelectorAll(".palette-tool")
      tool = toolEl.getAttribute("data-tool")
      canvasEl = toolEl.querySelector("canvas")
      @drawPaletteTool(tool, canvasEl)

    palette.addEventListener("pointerdown", @palettePointerDown)

  drawPaletteTool: (tool, canvasEl) ->
    canvas = new Canvas(canvasEl)
    if tool == "select"

    else if tool == "point"
      canvas.draw(new Geo.Point(0, 0))

    else if tool == "lineSegment"
      p1 = new Geo.Point(-10, -10)
      p2 = new Geo.Point(10, 10)
      l = new Geo.Line(p1, p2)
      canvas.draw(p1)
      canvas.draw(p2)
      canvas.draw(l)

  palettePointerDown: (e) =>
    toolEl = e.target.closest(".palette-tool")
    return unless toolEl?
    tool = toolEl.getAttribute("data-tool")
    @selectTool(tool)

  selectTool: (tool) ->
    @tool = tool
    palette = document.querySelector("#palette")
    for toolEl in palette.querySelectorAll(".palette-tool")
      toolEl.removeAttribute("data-selected")
    toolEl = palette.querySelector(".palette-tool[data-tool='#{tool}']")
    toolEl.setAttribute("data-selected", "")


  # ===========================================================================
  # Canvas
  # ===========================================================================

  setupCanvas: ->
    canvasEl = document.getElementById("c")
    @canvas = new Canvas(canvasEl)

    window.addEventListener("resize", @resize)
    @resize()

    canvasEl.addEventListener("pointerenter", @canvasPointerEnter)
    canvasEl.addEventListener("pointerleave", @canvasPointerLeave)
    canvasEl.addEventListener("pointerdown", @canvasPointerDown)
    canvasEl.addEventListener("pointermove", @canvasPointerMove)
    canvasEl.addEventListener("pointerup", @canvasPointerUp)

  resize: =>
    @canvas.setupSize()
    @draw()

  canvasPointerEnter: (e) =>
    if @tool == "point"
      if !@moving
        @moving = new Model.Point(new Geo.Point(0, 0))
        @context.objects.push(@moving)
    @draw()

  canvasPointerLeave: (e) =>
    if @tool == "point"
      if @moving
        @context.objects = _.without(@context.objects, @moving)
        @moving = null
    @draw()

  canvasPointerDown: (e) =>

  canvasPointerMove: (e) =>
    if @tool == "point"
      if @moving
        pointerPosition = new Geo.Point(e.clientX, e.clientY)
        workspacePosition = @canvas.browserToWorkspace(pointerPosition)
        @moving.point = workspacePosition
    @draw()

  canvasPointerUp: (e) =>
    if @tool == "point"
      @moving = null
    @draw()

  draw: ->
    @canvas.clear()
    @canvas.drawAxes()

    addresses = @model.addresses()
    for address in addresses
      object = address.evaluate()
      @canvas.draw(object)