mousePosition = [0, 0]
ctx = null
width = null
height = null



setup = ->
  resize()

  window.addEventListener "resize", resize

  document.addEventListener "pointermove", pointermove
  document.addEventListener "pointerup", pointerup


resize = ->
  canvas = document.querySelector("#c")
  width = canvas.width = document.body.clientWidth
  height = canvas.height = document.body.clientHeight
  ctx = canvas.getContext("2d")


canvasToWorkspace = (canvasPoint) ->
  workspacePoint = [
    canvasPoint[0] - width / 2
    canvasPoint[1] - height / 2
  ]


workspaceToCanvas = (workspacePoint) ->
  canvasPoint = [
    workspacePoint[0] + width / 2
    workspacePoint[1] + height / 2
  ]


rotate = (angle, point) ->
  return [
    Math.cos(angle) * point[0] - Math.sin(angle) * point[1]
    Math.sin(angle) * point[0] + Math.cos(angle) * point[1]
  ]





n = 12
points = [[0, 0]]


draw = ->
  ctx.fillStyle = "#000"
  ctx.strokeStyle = "#000"
  ctx.lineWidth = 1
  ctx.clearRect(0, 0, width, height)

  points[points.length - 1] = canvasToWorkspace(mousePosition)

  for i in [0...n]
    for point, pointNum in points
      rotatedPoint = rotate(Math.PI * 2 * i / n, point)
      drawPoint(rotatedPoint)

      if pointNum > 0
        previousPoint = points[pointNum - 1]
        rotatedPreviousPoint = rotate(Math.PI * 2 * i / n, previousPoint)
        drawLine(rotatedPoint, rotatedPreviousPoint)


pointermove = (e) ->
  mousePosition = [e.clientX, e.clientY]
  draw()


pointerup = (e) ->
  point = canvasToWorkspace(mousePosition)
  points.push(point)
  draw()




drawPoint = (point) ->
  point = workspaceToCanvas(point)
  ctx.beginPath()
  ctx.arc(point[0], point[1], 4.5, 0, Math.PI*2)
  ctx.fill()


drawLine = (point1, point2) ->
  point1 = workspaceToCanvas(point1)
  point2 = workspaceToCanvas(point2)
  ctx.beginPath()
  ctx.moveTo(point1...)
  ctx.lineTo(point2...)
  ctx.stroke()


setup()