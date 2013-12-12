EditorTool = {}


class EditorTool.Select
  constructor: (@editor) ->
    @selectedRef = null

  pointerDown: (e) ->
    found = @editor.refsNearPointer(e)
    if found.length > 0
      @selectedRef = found[0]
    else
      @selectedRef = null

  pointerMove: (e) ->
    return unless @selectedRef
    workspacePosition = @editor.workspacePosition(e)
    localPoint = @selectedRef.path.globalToLocal(workspacePosition)
    @selectedRef.object.point = localPoint

  pointerUp: (e) ->
    @selectedRef = null

  pointerLeave: (e) ->



class EditorTool.Point
  constructor: (@editor) ->
    @provisionalPoint = null

  pointerDown: (e) ->

  pointerMove: (e) ->
    if !@provisionalPoint
      @provisionalPoint = new Model.Point(new Geo.Point(0, 0))
      @editor.contextWreath.objects.push(@provisionalPoint)

    workspacePosition = @editor.workspacePosition(e)
    @provisionalPoint.point = workspacePosition

  pointerUp: (e) ->
    return unless @provisionalPoint
    @provisionalPoint = null

  pointerLeave: (e) ->
    return unless @provisionalPoint
    @editor.removeObject(@provisionalPoint)
    @provisionalPoint = null


class EditorTool.LineSegment
  constructor: (@editor) ->
    @lastRef = null
    @provisionalPoint = null
    @provisionalLine = null

  pointerDown: (e) ->
  pointerMove: (e) ->
    if !@provisionalPoint
      @provisionalPoint = new Model.Point(new Geo.Point(0, 0))
      @editor.contextWreath.objects.push(@provisionalPoint)
      if @lastRef
        # TODO
        path = new Ref.Path([wreath: @editor.contextWreath, op: 0])
        start = @lastRef
        end = new Ref(path, @provisionalPoint)
        @provisionalLine = new Model.Line(start, end)
        @editor.contextWreath.objects.push(@provisionalLine)

    # Snapping
    snapRef = @snapRef(e)
    if snapRef
      moveToPoint = snapRef.evaluate()
    else
      moveToPoint = @editor.workspacePosition(e)
    @provisionalPoint.point = moveToPoint

  pointerUp: (e) ->
    return unless @provisionalPoint
    snapRef = @snapRef(e)
    if snapRef
      if @provisionalLine
        @provisionalLine.end = snapRef
        @editor.removeObject(@provisionalPoint)
        @lastRef = null
      else
        @editor.removeObject(@provisionalPoint)
        @lastRef = snapRef
    else
      path = new Ref.Path([wreath: @editor.contextWreath, op: 0])
      @lastRef = new Ref(path, @provisionalPoint)
    @provisionalPoint = null
    @provisionalLine = null

  pointerLeave: (e) ->
    return unless @provisionalPoint
    @editor.removeObject(@provisionalPoint)
    @editor.removeObject(@provisionalLine) if @provisionalLine
    @provisionalPoint = null
    @provisionalLine = null

  snapRef: (e) ->
    snapRefs = @editor.refsNearPointer(e)
    snapRefs = _.reject snapRefs, (snapRef) =>
      snapRef.object == @provisionalPoint
    if snapRefs.length > 0
      return snapRefs[0]
    else
      return null