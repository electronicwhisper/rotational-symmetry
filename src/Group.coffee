class Group
  constructor: (@n) ->

  derive: (point, op) ->
    angle = 2 * Math.PI * (op / @n)
    return @rotate_(point, angle)

  invert: (point, op) ->
    return @derive(point, -op)

  ops: ->
    return [0...@n]

  rotate_: (point, angle) ->
    x = Math.cos(angle) * point.x - Math.sin(angle) * point.y
    y = Math.sin(angle) * point.x + Math.cos(angle) * point.y
    return new Point(x, y)