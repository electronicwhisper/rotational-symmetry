class Editor
  constructor: ->
    @mode = "select"
    @setupPalette()


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
    @mode = tool
    palette = document.querySelector("#palette")
    for toolEl in palette.querySelectorAll(".palette-tool")
      toolEl.removeAttribute("data-selected")
    toolEl = palette.querySelector(".palette-tool[data-tool='#{tool}']")
    toolEl.setAttribute("data-selected", "")