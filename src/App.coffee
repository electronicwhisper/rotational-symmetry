window.App = class App
  constructor: ->
    el = document.getElementById("c")
    @canvas = new Canvas(el)

    @model = @setupModel()

    window.addEventListener("resize", @resize)
    document.addEventListener("mousedown", @mousedown)
    document.addEventListener("mousemove", @mousemove)
    document.addEventListener("mouseup", @mouseup)
    @resize()


  resize: =>
    @canvas.el.width = document.body.clientWidth
    @canvas.el.height = document.body.clientHeight
    @draw()


  setupModel: ->
    center = new Model.Point(new Geo.Point(100, 0))
    centerAddress = new Model.Address(new Model.Path(), center)
    model = new Model.RotationWreath(centerAddress, 9)
    return model



  mousedown: (e) =>
    e.preventDefault()
    mousePosition = new Geo.Point(e.clientX, e.clientY)
    mousePoint = @canvas.canvasToWorkspace(mousePosition)

    point = new Model.Point(mousePoint)

    @model.objects.push(point)
    console.log @model

    @draw()


  mousemove: (e) =>


  mouseup: (e) =>


  draw: ->
    @canvas.clear()
    @canvas.drawAxes()

    addresses = @model.addresses()
    for address in addresses
      object = address.evaluate()
      @canvas.draw(object)
