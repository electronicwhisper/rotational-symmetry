class Canvas
  constructor: (@el) ->
    @ctx = @el.getContext("2d")
    @setupSize()

  width: -> @el.width
  height: -> @el.height

  setupSize: ->
    rect = @el.getBoundingClientRect()
    @el.width = rect.width
    @el.height = rect.height

  browserToCanvas: (browserPoint) ->
    rect = @el.getBoundingClientRect()
    x = browserPoint.x - rect.left
    y = browserPoint.y - rect.top
    return canvasPoint = new Geo.Point(x, y)

  browserToWorkspace: (browserPoint) ->
    canvasPoint = @browserToCanvas(browserPoint)
    return workspacePoint = @canvasToWorkspace(canvasPoint)

  canvasToWorkspace: (canvasPoint) ->
    x = canvasPoint.x - @width() / 2
    y = canvasPoint.y - @height() / 2
    return workspacePoint = new Geo.Point(x, y)

  workspaceToCanvas: (workspacePoint) ->
    x = workspacePoint.x + @width() / 2
    y = workspacePoint.y + @height() / 2
    return canvasPoint = new Geo.Point(x, y)


  # ===========================================================================
  # Drawing
  # ===========================================================================

  clear: ->
    @ctx.clearRect(0, 0, @width(), @height())

  drawAxes: ->
    @ctx.beginPath()
    @ctx.moveTo(@width()/2, 0)
    @ctx.lineTo(@width()/2, @height())
    @ctx.strokeStyle = "#ccc"
    @ctx.lineWidth = 1
    @ctx.stroke()
    @ctx.beginPath()
    @ctx.moveTo(0, @height()/2)
    @ctx.lineTo(@width(), @height()/2)
    @ctx.stroke()

  draw: (object) ->
    if object instanceof Geo.Point
      @drawPoint(object)
    else if object instanceof Geo.Line
      @drawLine(object)

  drawPoint: (point) ->
    point = @workspaceToCanvas(point)
    @ctx.beginPath()
    @ctx.arc(point.x, point.y, 3.5, 0, Math.PI*2)
    @ctx.fillStyle = "#000"
    @ctx.fill()

  drawLine: (line) ->
    start = @workspaceToCanvas(line.start)
    end = @workspaceToCanvas(line.end)
    @ctx.beginPath()
    @ctx.moveTo(start.x, start.y)
    @ctx.lineTo(end.x, end.y)
    @ctx.strokeStyle = "#000"
    @ctx.lineWidth = 1
    @ctx.stroke()



