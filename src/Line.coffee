class Line
  constructor: (@start, @end) ->

  draw: (canvas) ->
    canvasStart = canvas.workspaceToCanvas(@start)
    canvasEnd = canvas.workspaceToCanvas(@end)

    ctx = canvas.ctx
    ctx.beginPath()
    ctx.moveTo(canvasStart.x, canvasStart.y)
    ctx.lineTo(canvasEnd.x, canvasEnd.y)

    ctx.lineWidth = 1
    ctx.strokeStyle = "#000"
    ctx.stroke()