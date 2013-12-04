window.App = class App
  constructor: ->
    el = document.getElementById("c")
    @canvas = new Canvas(el)

    @model = new Model.Wreath()

    window.addEventListener("resize", @resize)
    document.addEventListener("mousedown", @mousedown)
    document.addEventListener("mousemove", @mousemove)
    document.addEventListener("mouseup", @mouseup)
    @resize()


  resize: =>
    @canvas.el.width = document.body.clientWidth
    @canvas.el.height = document.body.clientHeight



  mousedown: (e) =>
    e.preventDefault()
    mousePosition = new Geo.Point(e.clientX, e.clientY)
    mousePoint = @canvas.canvasToWorkspace(mousePosition)

    point = new Model.Point(mousePoint)

    @model.fibers.push(point)

    @draw()


  mousemove: (e) =>


  mouseup: (e) =>


  draw: ->
    @canvas.clear()

    addresses = @model.addresses()
    for address in addresses
      object = address.evaluate()
      @canvas.draw(object)
