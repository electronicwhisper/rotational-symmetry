window.App = class App
  constructor: ->
    el = document.getElementById("c")
    @canvas = new Canvas(el)

    @model = new Model()

    window.addEventListener("resize", @resize_)
    document.addEventListener("mousedown", @mousedown)
    document.addEventListener("mousemove", @mousemove)
    document.addEventListener("mouseup", @mouseup)
    @resize_()

    @moving_ = null
    @last_ = null


  resize_: =>
    @canvas.el.width = document.body.clientWidth
    @canvas.el.height = document.body.clientHeight



  mousedown: (e) =>
    e.preventDefault()
    mousePosition = new Point(e.clientX, e.clientY)
    found = @model.test(@canvas, mousePosition)

    didFind = found?

    if !found
      point = @canvas.canvasToWorkspace(mousePosition)
      @model.points.push(point)
      found = {point, op: 0}

    @moving_ = found
    if @last_
      @model.lines.push({
        start: @last_
        end: @moving_
      })

    if didFind
      @last_ = null
    else
      @last_ = @moving_

    @draw()


  mousemove: (e) =>
    if @moving_
      mousePosition = new Point(e.clientX, e.clientY)

      point = @canvas.canvasToWorkspace(mousePosition)

      point = @model.group.invert(point, @moving_.op)

      @moving_.point.setToPoint(point)

      @draw()


  mouseup: (e) =>
    @moving_ = null
    @draw()


  draw: ->
    @canvas.clear()
    @model.draw(@canvas)