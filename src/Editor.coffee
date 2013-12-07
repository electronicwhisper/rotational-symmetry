class Editor
  constructor: ->
    @tool = new Editor.Select(this)
    @contextWreath = null

    @setupModel()
    @setupPalette()
    @setupCanvas()


  # ===========================================================================
  # Model
  # ===========================================================================

  setupModel: ->
    @model = new Model.IdentityWreath()
    center = new Model.Point(new Geo.Point(0, 0))
    @model.objects.push(center)

    centerAddress = new Model.Address(new Model.Path([{wreath: @model, op: 0}]), center)
    rotation = new Model.RotationWreath(centerAddress, 9)
    @model.objects.push(rotation)

    @contextWreath = rotation


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
    @tool = new Editor[toolName](this)
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
    @canvas.clear()
    @canvas.drawAxes()

    addresses = @model.addresses()
    for address in addresses
      object = address.evaluate()
      @canvas.drawObject(object)


  addressesNearPointer: (e) ->
    pointerPosition = new Geo.Point(e.clientX, e.clientY)
    canvasPosition = @canvas.browserToCanvas(pointerPosition)

    result = []
    addresses = @model.addresses()
    for address in addresses
      object = address.evaluate()
      isNear = @canvas.isObjectNearPoint(object, canvasPosition)
      if isNear
        result.push(address)
    return result



class Editor.Select
  constructor: (@editor) ->
    @selectedAddress = null

  pointerDown: (e) ->
    found = @editor.addressesNearPointer(e)
    if found.length > 0
      @selectedAddress = found[0]
    else
      @selectedAddress = null

  pointerMove: (e) ->
    return unless @selectedAddress
    workspacePosition = @editor.workspacePosition(e)
    localPoint = @selectedAddress.path.globalToLocal(workspacePosition)
    @selectedAddress.object.point = localPoint

  pointerUp: (e) ->
    @selectedAddress = null

  pointerLeave: (e) ->



class Editor.Point
  constructor: (@editor) ->
    @provisionalPoint = null

  pointerDown: (e) ->

  pointerMove: (e) ->
    if !@provisionalPoint
      @provisionalPoint = new Model.Point(new Geo.Point(0, 0))
      @editor.contextWreath.objects.push(@provisionalPoint)

    workspacePosition = @editor.workspacePosition(e)
    @provisionalPoint.point = workspacePosition

  pointerUp: (e) ->
    return unless @provisionalPoint
    @provisionalPoint = null

  pointerLeave: (e) ->
    return unless @provisionalPoint
    contextWreath = @editor.contextWreath
    contextWreath.objects = _.without(contextWreath.objects, @provisionalPoint)
    @provisionalPoint = null


class Editor.LineSegment
  constructor: (@editor) ->
    @lastPoint = null
    @provisionalPoint = null
    @provisionalLine = null

  pointerDown: (e) ->
  pointerMove: (e) ->
    if !@provisionalPoint
      @provisionalPoint = new Model.Point(new Geo.Point(0, 0))
      @editor.contextWreath.objects.push(@provisionalPoint)
      if @lastPoint
        # TODO
        path = new Model.Path([wreath: @editor.contextWreath, op: 0])
        start = new Model.Address(path, @lastPoint)
        end = new Model.Address(path, @provisionalPoint)
        @provisionalLine = new Model.Line(start, end)
        @editor.contextWreath.objects.push(@provisionalLine)

    workspacePosition = @editor.workspacePosition(e)
    @provisionalPoint.point = workspacePosition

  pointerUp: (e) ->
    return unless @provisionalPoint
    @lastPoint = @provisionalPoint
    @provisionalPoint = null
    @provisionalLine = null

  pointerLeave: (e) ->
    return unless @provisionalPoint
    contextWreath = @editor.contextWreath
    contextWreath.objects = _.without(contextWreath.objects, @provisionalPoint, @provisionalLine)
    @provisionalPoint = null
    @provisionalLine = null

###

Concepts:

  Moving - point to move with pointermove events

  Provisional - geometries which would be deleted on pointerleave


makeProvisional

removeProvisional

moveMoving



Point
  make a point
  *DONE

Line
  make a point
  make a point, make a line from current point to previous point





###