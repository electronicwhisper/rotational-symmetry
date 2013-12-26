Render = {}

Render.render = (canvas, editor) ->
  canvas.clear()

  model = editor.model

  refs = model.refs()
  for ref in refs
    object = ref.object

    if object instanceof Model.Point
      # # point = ref.path.localToGlobal(object.point)
      point = ref.evaluate()
      Render.drawPoint(canvas, point)

    else if object instanceof Model.Line
      if object.start? && object.end?
        start = ref.path.localToGlobal(object.start.evaluate())
        end = ref.path.localToGlobal(object.end.evaluate())
        Render.drawLine(canvas, start, end)

    else if object instanceof Model.Circle
      if object.center? && object.radiusPoint?
        center = ref.path.localToGlobal(object.center.evaluate())
        radiusPoint = ref.path.localToGlobal(object.radiusPoint.evaluate())
        Render.drawCircle(canvas, center, radiusPoint)

    else if object instanceof Model.RotationWreath
      center = ref.path.localToGlobal(object.center.evaluate())
      Render.drawRotationWreath(canvas, center, object.n)

  for pointRef in model.pointRefs()
    point = pointRef.evaluate()
    Render.drawPoint(canvas, point)



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


Render.drawCircle = (canvas, center, radiusPoint, opts={}) ->
  center = canvas.workspaceToCanvas(center)
  radiusPoint = canvas.workspaceToCanvas(radiusPoint)
  radius = do ->
    dx = center.x - radiusPoint.x
    dy = center.y - radiusPoint.y
    Math.sqrt(dx*dx + dy*dy)
  ctx = canvas.ctx

  ctx.save()
  ctx.beginPath()
  ctx.arc(center.x, center.y, radius, 0, Math.PI*2)
  ctx.strokeStyle = "#000"
  ctx.lineWidth = 0.6
  ctx.stroke()
  ctx.restore()


Render.drawRotationWreath = (canvas, center, n, opts={}) ->
  center = canvas.workspaceToCanvas(center)
  ctx = canvas.ctx

  color = "purple"

  ctx.save()

  ctx.beginPath()
  ctx.arc(center.x, center.y, 2.5, 0, Math.PI*2)
  ctx.fillStyle = color
  ctx.fill()

  ctx.font = "10px monaco"
  ctx.fillText(n, center.x + 4, center.y - 4)

  ctx.restore()
