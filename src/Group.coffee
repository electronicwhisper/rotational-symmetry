class Group
  constructor: (@n) ->

  derive: (point, op) ->
    angle = 2 * Math.PI * (op / @n)
    get = =>
      @rotate_(angle, point)
    set = (newDerivedPoint) =>
      @rotate_(-angle, point)
    return new DerivedPoint(get, set)

  deriveAll: (point) ->
    return for i in [0...@n]
      @derive(point, i)

  rotate_: (point, angle) ->
    x = Math.cos(angle) * point.x - Math.sin(angle) * point.y
    y = Math.sin(angle) * point.x + Math.cos(angle) * point.y
    return new Point(x, y)