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
    throw "Called evaluate on a non-point Ref" unless @object instanceof Model.Point
    point = @object.point
    return @path.localToGlobal(point)

  isEqual: (otherRef) ->
    return @path.isEqual(otherRef.path) && @object == otherRef.object


class Ref.Path
  constructor: (@steps=[]) ->
    # Check it
    for step in @steps
      unless step.wreath? && step.op?
        console.error("bad path", @steps)

  prepend: (steps) ->
    if steps instanceof Ref.Path
      steps = steps.steps
    else if !_.isArray(steps)
      steps = [steps]

    return new Ref.Path(steps.concat(@steps))

  isEqual: (otherPath) ->
    for step, i in @steps
      otherStep = otherPath.steps[i]
      unless otherStep && step.wreath == otherStep.wreath && step.op == otherStep.op
        return false
    return true

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