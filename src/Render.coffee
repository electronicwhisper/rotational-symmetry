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

    else if object instanceof Model.ReflectionWreath
      if object.p1? && object.p2?
        p1 = ref.path.localToGlobal(object.p1.evaluate())
        p2 = ref.path.localToGlobal(object.p2.evaluate())
        Render.drawReflectionWreath(canvas, p1, p2)

  for pointRef in model.pointRefs()
    opts = {}
    if editor.movingPointRef?.object == pointRef.object
      opts.color = "#f00"
    point = pointRef.evaluate()
    Render.drawPoint(canvas, point, opts)



Render.drawPoint = (canvas, point, opts={}) ->
  point = canvas.workspaceToCanvas(point)
  ctx = canvas.ctx

  ctx.save()
  ctx.beginPath()
  ctx.arc(point.x, point.y, 2.5, 0, Math.PI*2)
  ctx.fillStyle = opts.color ? "#333"
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
  ctx.strokeStyle = opts.color ? "#000"
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
  ctx.strokeStyle = opts.color ? "#000"
  ctx.lineWidth = 0.6
  ctx.stroke()
  ctx.restore()


Render.drawRotationWreath = (canvas, center, n, opts={}) ->
  center = canvas.workspaceToCanvas(center)
  ctx = canvas.ctx

  color = opts.color ? "purple"

  ctx.save()

  ctx.beginPath()
  ctx.arc(center.x, center.y, 2.5, 0, Math.PI*2)
  ctx.fillStyle = color
  ctx.fill()

  ctx.font = "10px monaco"
  ctx.fillText(n, center.x + 4, center.y - 4)

  ctx.restore()


Render.drawReflectionWreath = (canvas, p1, p2, opts={}) ->
  p1 = canvas.workspaceToCanvas(p1)
  p2 = canvas.workspaceToCanvas(p2)
  ctx = canvas.ctx

  ctx.save()

  nw = new Geo.Point(0, 0)
  ne = new Geo.Point(canvas.width(), 0)
  sw = new Geo.Point(0, canvas.height())
  se = new Geo.Point(canvas.width(), canvas.height())

  start = intersectionPointForLines(p1, p2, nw, ne) ? intersectionPointForLines(p1, p2, nw, sw)
  end = intersectionPointForLines(p1, p2, sw, se) ? intersectionPointForLines(p1, p2, ne, se)

  return unless start? && end?

  ctx.beginPath()
  ctx.moveTo(start.x, start.y)
  ctx.lineTo(end.x, end.y)

  ctx.strokeStyle = opts.color ? "purple"
  ctx.lineWidth = 0.6
  ctx.setLineDash([5])
  ctx.stroke()

  ctx.restore()

