EditorTool = {}


class EditorTool.Select
  constructor: (@editor) ->

  pointerDown: (e) ->
    found = @editor.refsNearPointer(e)
    if found.length > 0
      @editor.startMove(e, found[0])


class EditorTool.LineSegment
  constructor: (@editor) ->
    @provisionalLine = null

  pointerMove: (e) ->
    if !@provisionalLine
      pointRef = @editor.startMove(e)
      @provisionalLine = new Model.Line(pointRef, null)
      @editor.contextWreath.objects.push(@provisionalLine)

  pointerUp: (e) ->
    if @provisionalLine
      if !@provisionalLine.end
        @provisionalLine.end = @editor.startMove(e)
      else
        @provisionalLine = null
        @editor.endMove()

  pointerLeave: (e) ->
    if @provisionalLine && !@provisionalLine.end
      @editor.removeObject(@provisionalLine)
      @provisionalLine = null



class EditorTool.Circle
  constructor: (@editor) ->
    @provisionalCircle = null

  pointerMove: (e) ->
    if !@provisionalCircle
      pointRef = @editor.startMove(e)
      @provisionalCircle = new Model.Circle(pointRef, null)
      @editor.contextWreath.objects.push(@provisionalCircle)

  pointerUp: (e) ->
    if @provisionalCircle
      if !@provisionalCircle.radiusPoint
        @provisionalCircle.radiusPoint = @editor.startMove(e)
      else
        @provisionalCircle = null
        @editor.endMove()

  pointerLeave: (e) ->
    if @provisionalCircle && !@provisionalCircle.radiusPoint
      @editor.removeObject(@provisionalCircle)
      @provisionalCircle = null



class EditorTool.RotationWreath
  constructor: (@editor) ->
    @provisionalRotationWreath = null

  pointerMove: (e) ->
    if !@provisionalRotationWreath
      pointRef = @editor.startMove(e)
      @provisionalRotationWreath = new Model.RotationWreath(pointRef, 12)
      @editor.contextWreath.objects.push(@provisionalRotationWreath)

  pointerUp: (e) ->
    return unless @provisionalRotationWreath
    @provisionalRotationWreath = null

  pointerLeave: (e) ->
    return unless @provisionalRotationWreath
    @editor.removeObject(@provisionalRotationWreath)
    @provisionalRotationWreath = null



class EditorTool.ReflectionWreath
  constructor: (@editor) ->
    @provisionalReflectionWreath = null

  pointerMove: (e) ->
    if !@provisionalReflectionWreath
      pointRef = @editor.startMove(e)
      @provisionalReflectionWreath = new Model.ReflectionWreath(pointRef, null)
      @editor.contextWreath.objects.push(@provisionalReflectionWreath)

  pointerUp: (e) ->
    if @provisionalReflectionWreath
      if !@provisionalReflectionWreath.p2
        @provisionalReflectionWreath.p2 = @editor.startMove(e)
      else
        @provisionalReflectionWreath = null
        @editor.endMove()

  pointerLeave: (e) ->
    if @provisionalReflectionWreath && !@provisionalReflectionWreath.p2
      @editor.removeObject(@provisionalReflectionWreath)
      @provisionalReflectionWreath = null