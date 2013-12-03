###

PointRef
  path: [{wreath, op}]
  point:

###

class PointRef
  constructor: (@point, @path=[]) ->

  evaluate: ->
    point = @point
    # TODO: reverse?
    for step in @path
      wreath = step.wreath
      op = step.op
      point = wreath.control.derive(point, op)
    return point


class LineRef
  constructor: (@start, @end) ->

  evaluate: ->
    start = @start.evaluate()
    end = @end.evaluate()
    return new Line(start, end)