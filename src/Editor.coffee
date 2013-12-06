class Editor
  constructor: ->
    @tool = "select"

    @setupModel()
    @setupPalette()
    @setupCanvas()


  # ===========================================================================
  # Model
  # ===========================================================================

  setupModel: ->
    center = new Model.Point(new Geo.Point(100, 0))
    centerAddress = new Model.Address(new Model.Path(), center)
    @model = new Model.RotationWreath(centerAddress, 9)


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

    canvasEl.addEventListener("pointerdown", @canvasPointerDown)
    canvasEl.addEventListener("pointermove", @canvasPointerMove)
    canvasEl.addEventListener("pointerup", @canvasPointerUp)

  resize: =>
    @canvas.setupSize()
    @draw()

  canvasPointerDown: (e) =>

  canvasPointerMove: (e) =>

  canvasPointerUp: (e) =>


  draw: ->
    @canvas.clear()
    @canvas.drawAxes()

    addresses = @model.addresses()
    for address in addresses
      object = address.evaluate()
      @canvas.draw(object)