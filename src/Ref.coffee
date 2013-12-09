###

A Ref refers to a specific point/line/etc within the context of a series of
group transformations. For example, a point under the second operation of a
five-fold rotation wreath.

Every object on the screen has an associated Ref. (We use Wreath.refs() to
generate all descendant refs.) There can also be Refs that are not drawn on
the screen (for example a Ref to a point under a group operation for use as
the endpoint of a line, even though the point does not live under that
wreath.)

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