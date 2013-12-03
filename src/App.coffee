window.App = class App
  constructor: ->
    el = document.getElementById("c")
    @canvas = new Canvas(el)

    @model = new Model()
    @model.points.push(new Point(0, 0))

    window.addEventListener("resize", @resize_)
    document.addEventListener("mousemove", @mousemove_)
    document.addEventListener("mouseup", @mouseup_)
    @resize_()


  resize_: =>
    @canvas.el.width = document.body.clientWidth
    @canvas.el.height = document.body.clientHeight


  mousemove_: (e) =>
    mousePosition = new Point(e.clientX, e.clientY)

    point = @canvas.canvasToWorkspace(mousePosition)

    _.last(@model.points).setToPoint(point)

    @canvas.clear()
    @model.draw(@canvas)


  mouseup_: (e) =>
    mousePosition = new Point(e.clientX, e.clientY)
    point = @canvas.canvasToWorkspace(mousePosition)

    startPoint = _.last(@model.points)

    @model.points.push(point)
    @model.lines.push({
      start: {point: startPoint, op: 0}
      end: {point: point, op: 0}
    })