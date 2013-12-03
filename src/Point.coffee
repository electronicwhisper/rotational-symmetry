class Point
  constructor: (@x, @y) ->

  size: 4

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


class DerivedPoint
  constructor: (@get, @set) ->