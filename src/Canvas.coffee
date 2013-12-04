class Canvas
  constructor: (@el) ->
    @ctx = @el.getContext("2d")

  width: -> @el.width
  height: -> @el.height

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

  draw: (object) ->
    if object instanceof Geo.Point
      @drawPoint(object)
    else if object instanceof Geo.Line
      @drawLine(object)

  drawPoint: (point) ->
    point = @workspaceToCanvas(point)
    @ctx.beginPath()
    @ctx.arc(point.x, point.y, 4, 0, Math.PI*2)
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



