###

Things we want to recurse:
  All the objects (descendants)
  All the refs to objects (e.g. exponentiating it out)


###

Model = {}


class Model.Base
  name: ""
  points: -> []
  children: -> []


class Model.Point extends Model.Base
  name: "Point"

  constructor: (@point) ->


class Model.Line extends Model.Base
  name: "Line"
  points: -> [@start, @end]

  constructor: (@start, @end) ->


class Model.Wreath extends Model.Base
  name: "Group"
  children: -> @objects

  constructor: ->
    @objects = []

  ops: -> [0]
  inverse: (op) -> op
  perform: (op, point) -> return point

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

  pointRefs: ->
    result = []

    add = (ref, pointRef) ->
      path = pointRef.path.prepend(ref.path)
      ref = new Ref(path, pointRef.object)
      for existingRef in result
        if ref.isEqual(existingRef)
          return
      result.push(ref)

    for ref in @refs()
      for pointRef in ref.object.points()
        add(ref, pointRef)

    return result


class Model.RotationWreath extends Model.Wreath
  name: "Rotation Group"
  points: -> [@center]

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
