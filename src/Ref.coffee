###

A Ref refers to a specific point/line/etc that can be seen on the screen. E.g.
if there's a point within a 5-fold rotational wreath, that point would
"generate" 5 Refs.

###

class Ref
  constructor: (@path, @object) ->
  evaluate: ->
    if @object instanceof Model.Point
      point = @object.point
      return @path.localToGlobal(point)
    else if @object instanceof Model.Line
      start = @path.localToGlobal(@object.start.evaluate())
      end = @path.localToGlobal(@object.end.evaluate())
      return new Geo.Line(start, end)


class Ref.Path
  constructor: (@steps=[]) ->

  prepend: (step) ->
    return new Ref.Path([step].concat(@steps))

  globalToLocal: (point) ->
    for step in @steps
      {wreath, op} = step
      inverseOp = wreath.inverse(op)
      point = wreath.perform(inverseOp, point)
    return point

  localToGlobal: (point) ->
    for step in @steps.slice().reverse()
      {wreath, op} = step
      point = wreath.perform(op, point)
    return point