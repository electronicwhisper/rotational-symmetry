Render = {}

Render.render = (canvas, editor) ->
  canvas.clear()

  model = editor.model

  refs = model.refs()
  for ref in refs
    object = ref.object

    if object instanceof Model.Point
      # point = ref.path.localToGlobal(object.point)
      point = ref.evaluate()
      Render.drawPoint(canvas, point)

    else if object instanceof Model.Line
      start = ref.path.localToGlobal(object.start.evaluate())
      end = ref.path.localToGlobal(object.end.evaluate())
      Render.drawLine(canvas, start, end)

    else if object instanceof Model.RotationWreath
      center = ref.path.localToGlobal(object.center.evaluate())
      Render.drawRotationWreath(canvas, center, object.n)



Render.drawPoint = (canvas, point, opts={}) ->
  point = canvas.workspaceToCanvas(point)
  ctx = canvas.ctx

  ctx.save()
  ctx.beginPath()
  ctx.arc(point.x, point.y, 2.5, 0, Math.PI*2)
  ctx.fillStyle = "#333"
  ctx.fill()
  ctx.restore()


Render.drawLine = (canvas, start, end, opts={}) ->
  start = canvas.workspaceToCanvas(start)
  end = canvas.workspaceToCanvas(end)
  ctx = canvas.ctx

  ctx.save()
  ctx.beginPath()
  ctx.moveTo(start.x, start.y)
  ctx.lineTo(end.x, end.y)
  ctx.strokeStyle = "#000"
  ctx.lineWidth = 0.6
  ctx.stroke()
  ctx.restore()


Render.drawRotationWreath = (canvas, center, n, opts={}) ->
  center = canvas.workspaceToCanvas(center)
  ctx = canvas.ctx

  ctx.save()

  ctx.beginPath()
  ctx.arc(center.x, center.y, 8, 0, Math.PI*2)
  ctx.globalAlpha = 1
  ctx.fillStyle = "#fff"
  ctx.fill()

  ctx.beginPath()
  ctx.arc(center.x, center.y, 8, 0, Math.PI*2)
  ctx.globalAlpha = 0.25
  ctx.fillStyle = "#00c"
  ctx.fill()

  ctx.beginPath()
  ctx.moveTo(center.x, center.y)
  ctx.lineTo(center.x + 8, center.y)
  ctx.arc(center.x, center.y, 8, 0, -Math.PI*2 / n)
  ctx.lineTo(center.x, center.y)
  ctx.globalAlpha = 1
  ctx.fillStyle = "#00c"
  ctx.fill()

  ctx.restore()
