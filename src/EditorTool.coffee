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

    snapRef = @snapRef(e)
    if snapRef
      moveToPoint = snapRef.evaluate()
    else
      moveToPoint = @editor.workspacePosition(e)
    @selectedRef.object.point = @selectedRef.path.globalToLocal(moveToPoint)

    # workspacePosition = @editor.workspacePosition(e)
    # localPoint = @selectedRef.path.globalToLocal(workspacePosition)
    # @selectedRef.object.point = localPoint

  pointerUp: (e) ->
    snapRef = @snapRef(e)
    if snapRef
      @editor.mergePointRefs(snapRef, @selectedRef)
    @selectedRef = null

  pointerLeave: (e) ->

  snapRef: (e) ->
    @editor.findSnapRef(e, [@selectedRef.object])



class EditorTool.LineSegment
  constructor: (@editor) ->
    @provisionalLine = null
    @previousPointRef = null
    @currentPointRef = null

  makeNewCurrentPointRef: ->
    point = new Model.Point(new Geo.Point(0, 0))
    path = new Ref.Path([])
    @currentPointRef = new Ref(path, point)

  moveCurrentPointRef: (e) ->
    snapRef = @snapRef(e)
    if snapRef
      moveToPoint = snapRef.evaluate()
    else
      moveToPoint = @editor.workspacePosition(e)
    @currentPointRef.object.point = moveToPoint

  pointerDown: (e) ->

  pointerMove: (e) ->
    if !@currentPointRef
      @makeNewCurrentPointRef()
      if @previousPointRef
        start = @previousPointRef
        end = @currentPointRef
      else
        start = @currentPointRef
        end = null
      @provisionalLine = new Model.Line(start, end)
      @editor.contextWreath.objects.push(@provisionalLine)

    @moveCurrentPointRef(e)

  pointerUp: (e) ->
    return unless @currentPointRef
    snapRef = @snapRef(e)

    if @previousPointRef
      if snapRef
        @provisionalLine.end = snapRef
        @currentPointRef = null
        @previousPointRef = null
        @provisionalLine = null
      else
        @previousPointRef = @currentPointRef
        @currentPointRef = null
        @provisionalLine = null
    else
      @previousPointRef = @currentPointRef
      @makeNewCurrentPointRef()
      @moveCurrentPointRef(e)
      @provisionalLine.start = snapRef ? @previousPointRef
      @provisionalLine.end = @currentPointRef

  pointerLeave: (e) ->
    return unless @currentPointRef
    @editor.removeObject(@provisionalLine) if @provisionalLine
    @currentPointRef = null
    @provisionalLine = null

  snapRef: (e) ->
    @editor.findSnapRef(e, [@currentPointRef.object])



class EditorTool.RotationWreath
  constructor: (@editor) ->
    @provisionalRotationWreath = null

  pointerDown: (e) ->

  pointerMove: (e) ->
    if !@provisionalRotationWreath
      point = new Model.Point(new Geo.Point(0, 0))
      path = new Ref.Path([])
      pointRef = new Ref(path, point)

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
