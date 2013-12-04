Model = {}


class Model.Point
  constructor: (@point) ->


class Model.Line
  constructor: (@start, @end) ->


class Model.Wreath
  constructor: ->
    @control = new Group(12)
    @fibers = []

  addresses: ->
    result = []
    for op in @control.ops()
      for fiber in @fibers
        if fiber instanceof Model.Wreath
          "TODO"
        else
          result.push(new Model.Address(fiber, [{wreath: this, op: op}]))
    return result


class Model.Address
  constructor: (@object, @path=[]) ->

  evaluate: ->
    if @object instanceof Model.Point
      point = @object.point
      for step in @path
        point = step.wreath.control.apply(step.op, point)
      return point
    else if @object instanceof Model.Line
      start = @object.start.evaluate()
      end = @object.end.evaluate()
      return new Geo.Line(start, end)





























