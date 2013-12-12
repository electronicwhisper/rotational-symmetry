class Editor
  constructor: ->
    @tool = new Editor.Select(this)
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
    rotation = new Model.RotationWreath(centerRef, 9)
    @model.objects.push(rotation)

    @contextWreath = rotation


  # ===========================================================================
  # Layer Manager
  # ===========================================================================

  setupLayerManager: ->
    @layerManager = new LayerManager(@model)


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
    @canvas.clear()
    # @canvas.drawAxes()

    refs = @model.refs()
    for ref in refs
      object = ref.evaluate()
      @canvas.drawObject(object)

    @layerManager.updateDOM()


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



class Editor.Select
  constructor: (@editor) ->
    @selectedRef = null

  pointerDown: (e) ->
    found = @editor.refsNearPointer(e)
    if found.length > 0
      @selectedRef = found[0]
    else
      @selectedRef = null

  pointerMove: (e) ->
    return unless @selectedRef
    workspacePosition = @editor.workspacePosition(e)
    localPoint = @selectedRef.path.globalToLocal(workspacePosition)
    @selectedRef.object.point = localPoint

  pointerUp: (e) ->
    @selectedRef = null

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
    @editor.removeObject(@provisionalPoint)
    @provisionalPoint = null


class Editor.LineSegment
  constructor: (@editor) ->
    @lastRef = null
    @provisionalPoint = null
    @provisionalLine = null

  pointerDown: (e) ->
  pointerMove: (e) ->
    if !@provisionalPoint
      @provisionalPoint = new Model.Point(new Geo.Point(0, 0))
      @editor.contextWreath.objects.push(@provisionalPoint)
      if @lastRef
        # TODO
        path = new Ref.Path([wreath: @editor.contextWreath, op: 0])
        start = @lastRef
        end = new Ref(path, @provisionalPoint)
        @provisionalLine = new Model.Line(start, end)
        @editor.contextWreath.objects.push(@provisionalLine)

    # Snapping
    snapRef = @snapRef(e)
    if snapRef
      moveToPoint = snapRef.evaluate()
    else
      moveToPoint = @editor.workspacePosition(e)
    @provisionalPoint.point = moveToPoint

  pointerUp: (e) ->
    return unless @provisionalPoint
    snapRef = @snapRef(e)
    if snapRef
      if @provisionalLine
        @provisionalLine.end = snapRef
        @editor.removeObject(@provisionalPoint)
        @lastRef = null
      else
        @editor.removeObject(@provisionalPoint)
        @lastRef = snapRef
    else
      path = new Ref.Path([wreath: @editor.contextWreath, op: 0])
      @lastRef = new Ref(path, @provisionalPoint)
    @provisionalPoint = null
    @provisionalLine = null

  pointerLeave: (e) ->
    return unless @provisionalPoint
    @editor.removeObject(@provisionalPoint)
    @editor.removeObject(@provisionalLine) if @provisionalLine
    @provisionalPoint = null
    @provisionalLine = null

  snapRef: (e) ->
    snapRefs = @editor.refsNearPointer(e)
    snapRefs = _.reject snapRefs, (snapRef) =>
      snapRef.object == @provisionalPoint
    if snapRefs.length > 0
      return snapRefs[0]
    else
      return null

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