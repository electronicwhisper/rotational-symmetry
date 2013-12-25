EditorTool = {}


class EditorTool.Select
  constructor: (@editor) ->

  pointerDown: (e) ->
    found = @editor.refsNearPointer(e)
    if found.length > 0
      @editor.startMove(e, found[0])

  pointerMove: (e) ->

  pointerUp: (e) ->

  pointerLeave: (e) ->




class EditorTool.LineSegment
  constructor: (@editor) ->
    @provisionalLine = null

  pointerDown: (e) ->

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
        @editor.movingPointRef = null

  pointerLeave: (e) ->
    if @provisionalLine && !@provisionalLine.end
      @editor.removeObject(@provisionalLine)
      @provisionalLine = null



class EditorTool.RotationWreath
  constructor: (@editor) ->
    @provisionalRotationWreath = null

  pointerDown: (e) ->

  pointerMove: (e) ->
    if !@provisionalRotationWreath
      pointRef = @editor.startMove(e)
      @provisionalRotationWreath = new Model.RotationWreath(pointRef, 12)
      @editor.contextWreath.objects.push(@provisionalRotationWreath)

    workspacePosition = @editor.workspacePosition(e)
    @provisionalRotationWreath.center.object.point = workspacePosition

  pointerUp: (e) ->
    return unless @provisionalRotationWreath
    @provisionalRotationWreath = null

  pointerLeave: (e) ->
    return unless @provisionalRotationWreath
    @editor.removeObject(@provisionalRotationWreath)
    @provisionalRotationWreath = null
