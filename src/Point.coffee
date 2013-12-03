class Point
  size: 4

  constructor: (@x, @y) ->

  setToPoint: (point) ->
    @x = point.x
    @y = point.y

  draw: (canvas) ->
    @path_(canvas)
    ctx = canvas.ctx
    ctx.fillStyle = "#000"
    ctx.fill()

  test: (canvas, canvasPoint) ->
    @path_(canvas)
    ctx = canvas.ctx
    return ctx.isPointInPath(canvasPoint.x, canvasPoint.y)

  path_: (canvas) ->
    canvasPoint = canvas.workspaceToCanvas(this)
    ctx = canvas.ctx
    ctx.beginPath()
    ctx.arc(canvasPoint.x, canvasPoint.y, @size, 0, Math.PI*2)