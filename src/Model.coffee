Model = {}


class Model.Point
  constructor: (@point) ->


class Model.Line
  constructor: (@start, @end) ->


class Model.Wreath
  constructor: ->
    @objects = []

  ops: -> throw new Error("Not implemented.")
  inverse: (op) -> throw new Error("Not implemented.")
  perform: (op, point) -> throw new Error("Not implemented.")

  addresses: ->
    result = []
    for op in @ops()
      for object in @objects
        if object instanceof Model.Wreath
          childAddresses = object.addresses()
          for childAddress in childAddresses
            path = childAddress.path.prepend({wreath: this, op: op})
            address = new Model.Address(path, childAddress.object)
            result.push(address)
        else
          path = new Model.Path([{wreath: this, op: op}])
          address = new Model.Address(path, object)
          result.push(address)
    return result


class Model.IdentityWreath extends Model.Wreath
  constructor: ->
    super()

  ops: -> [0]

  inverse: (op) -> op

  perform: (op, point) ->
    return point


class Model.RotationWreath extends Model.Wreath
  constructor: (@center, @n) ->
    super()

  ops: ->
    return [0...@n]

  inverse: (op) ->
    return -op

  perform: (op, point) ->
    angle = (op / @n) * 2*Math.PI
    centerPoint = @center.evaluate()
    v = new Geo.Point(point.x - centerPoint.x, point.y - centerPoint.y)
    v = @rotate_(angle, v)
    point = new Geo.Point(centerPoint.x + v.x, centerPoint.y + v.y)
    return point

  rotate_: (angle, point) ->
    x = Math.cos(angle) * point.x - Math.sin(angle) * point.y
    y = Math.sin(angle) * point.x + Math.cos(angle) * point.y
    return new Geo.Point(x, y)






class Model.Path
  constructor: (@steps=[]) ->

  prepend: (step) ->
    return new Model.Path([step].concat(@steps))

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



class Model.Address
  constructor: (@path, @object) ->

  evaluate: ->
    if @object instanceof Model.Point
      point = @object.point
      return @path.localToGlobal(point)
    else if @object instanceof Model.Line
      start = @path.localToGlobal(@object.start.evaluate())
      end = @path.localToGlobal(@object.end.evaluate())
      return new Geo.Line(start, end)


















