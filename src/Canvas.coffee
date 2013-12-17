###

A Canvas manages the quirks of the browser canvas element. It also keeps track
of the pan/zoom of the canvas by providing methods to convert from coordinate
spaces.

TODO: Move hit testing into Render.

###

class Canvas
  constructor: (@el) ->
    @ctx = @el.getContext("2d")
    @setupSize()

  width: -> @el.width / @ratio
  height: -> @el.height / @ratio

  setupSize: ->
    # Baloney via http://www.html5rocks.com/en/tutorials/canvas/hidpi/
    devicePixelRatio = window.devicePixelRatio || 1
    backingStoreRatio = @ctx.webkitBackingStorePixelRatio ||
                        @ctx.mozBackingStorePixelRatio ||
                        @ctx.msBackingStorePixelRatio ||
                        @ctx.oBackingStorePixelRatio ||
                        @ctx.backingStorePixelRatio || 1
    @ratio = devicePixelRatio / backingStoreRatio

    # @ratio = 1

    rect = @el.getBoundingClientRect()
    @el.width = rect.width * @ratio
    @el.height = rect.height * @ratio
    @ctx.setTransform(1, 0, 0, 1, 0, 0)
    @ctx.scale(@ratio, @ratio)

  browserToCanvas: (browserPoint) ->
    rect = @el.getBoundingClientRect()
    x = browserPoint.x - rect.left
    y = browserPoint.y - rect.top
    return canvasPoint = new Geo.Point(x, y)

  browserToWorkspace: (browserPoint) ->
    canvasPoint = @browserToCanvas(browserPoint)
    return workspacePoint = @canvasToWorkspace(canvasPoint)

  canvasToWorkspace: (canvasPoint) ->
    x = canvasPoint.x - @width() / 2
    y = canvasPoint.y - @height() / 2
    return workspacePoint = new Geo.Point(x, y)

  workspaceToCanvas: (workspacePoint) ->
    x = workspacePoint.x + @width() / 2
    y = workspacePoint.y + @height() / 2
    return canvasPoint = new Geo.Point(x, y)


  # ===========================================================================
  # Drawing Misc
  # ===========================================================================

  clear: ->
    @ctx.clearRect(0, 0, @width(), @height())

  drawAxes: ->
    @ctx.beginPath()
    @ctx.moveTo(@width()/2, 0)
    @ctx.lineTo(@width()/2, @height())
    @ctx.strokeStyle = "#ccc"
    @ctx.lineWidth = 1
    @ctx.stroke()
    @ctx.beginPath()
    @ctx.moveTo(0, @height()/2)
    @ctx.lineTo(@width(), @height()/2)
    @ctx.stroke()


  # ===========================================================================
  # Hit Testing Geo Objects
  # ===========================================================================

  isObjectNearPoint: (object, canvasPoint) ->
    if object instanceof Geo.Point
      return @isPointNearPoint(object, canvasPoint)
    else if object instanceof Geo.Line
      return @isLineNearPoint(object, canvasPoint)

  isPointNearPoint: (point, canvasPoint) ->
    point = @workspaceToCanvas(point)
    dx = point.x - canvasPoint.x
    dy = point.y - canvasPoint.y
    distanceSquared = (dx * dx) + (dy * dy)
    return distanceSquared < 15*15

  isLineNearPoint: (line, canvasPoint) ->
    # TODO
    return false



