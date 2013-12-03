window.App = class App
  constructor: ->
    el = document.getElementById("c")
    @canvas = new Canvas(el)

    window.addEventListener("resize", @resize_)
    document.addEventListener("mousemove", @mousemove_)
    @resize_()


  resize_: =>
    @canvas.el.width = document.body.clientWidth
    @canvas.el.height = document.body.clientHeight


  mousemove_: (e) =>
    mousePosition = new Point(e.clientX, e.clientY)

    point = @canvas.canvasToWorkspace(mousePosition)

    @canvas.clear()
    point.draw(@canvas)