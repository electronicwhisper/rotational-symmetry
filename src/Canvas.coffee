class Canvas
  constructor: (@el) ->
    @ctx = @el.getContext("2d")

  width: -> @el.width
  height: -> @el.height

  canvasToWorkspace: (canvasPoint) ->
    x = canvasPoint.x - @width() / 2
    y = canvasPoint.y - @height() / 2
    return workspacePoint = new Point(x, y)

  workspaceToCanvas: (workspacePoint) ->
    x = workspacePoint.x + @width() / 2
    y = workspacePoint.y + @height() / 2
    return canvasPoint = new Point(x, y)

  clear: ->
    @ctx.clearRect(0, 0, @width(), @height())