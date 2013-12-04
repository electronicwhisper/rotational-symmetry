class Group
  constructor: (@n) ->

  apply: (op, point) ->
    angle = 2 * Math.PI * (op / @n)
    return @rotate_(angle, point)

  invert: (op) ->
    return -op

  ops: ->
    return [0...@n]

  rotate_: (angle, point) ->
    x = Math.cos(angle) * point.x - Math.sin(angle) * point.y
    y = Math.sin(angle) * point.x + Math.cos(angle) * point.y
    return new Geo.Point(x, y)