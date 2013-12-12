Model = {}


class Model.Point
  name: "Point"
  constructor: (@point) ->


class Model.Line
  name: "Line"
  constructor: (@start, @end) ->


class Model.Wreath
  constructor: ->
    @objects = []

  ops: -> throw new Error("Not implemented.")
  inverse: (op) -> throw new Error("Not implemented.")
  perform: (op, point) -> throw new Error("Not implemented.")

  refs: ->
    result = []
    for op in @ops()
      for object in @objects
        if object instanceof Model.Wreath
          childRefs = object.refs()
          for childRef in childRefs
            path = childRef.path.prepend({wreath: this, op: op})
            ref = new Ref(path, childRef.object)
            result.push(ref)

        path = new Ref.Path([{wreath: this, op: op}])
        ref = new Ref(path, object)
        result.push(ref)
    return result


class Model.IdentityWreath extends Model.Wreath
  name: "Group"
  constructor: ->
    super()

  ops: -> [0]

  inverse: (op) -> op

  perform: (op, point) ->
    return point


class Model.RotationWreath extends Model.Wreath
  name: "Rotation Group"
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
