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



# class EditorTool.LineSegment
#   constructor: (@editor) ->
#     @lastRef = null
#     @provisionalPoint = null
#     @provisionalLine = null

#   pointerDown: (e) ->
#   pointerMove: (e) ->
#     if !@provisionalPoint
#       @provisionalPoint = new Model.Point(new Geo.Point(0, 0))
#       @editor.contextWreath.objects.push(@provisionalPoint)
#       if @lastRef
#         # TODO contextWreath should really be a Ref so that the following path can be correct.
#         path = new Ref.Path([wreath: @editor.contextWreath, op: 0])
#         start = @lastRef
#         end = new Ref(path, @provisionalPoint)
#         @provisionalLine = new Model.Line(start, end)
#         @editor.contextWreath.objects.push(@provisionalLine)

#     # Snapping
#     snapRef = @snapRef(e)
#     if snapRef
#       moveToPoint = snapRef.evaluate()
#     else
#       moveToPoint = @editor.workspacePosition(e)
#     @provisionalPoint.point = moveToPoint

#   pointerUp: (e) ->
#     return unless @provisionalPoint
#     snapRef = @snapRef(e)
#     if snapRef
#       if @provisionalLine
#         @provisionalLine.end = snapRef
#         @editor.removeObject(@provisionalPoint)
#         @lastRef = null
#       else
#         @editor.removeObject(@provisionalPoint)
#         @lastRef = snapRef
#     else
#       path = new Ref.Path([wreath: @editor.contextWreath, op: 0])
#       @lastRef = new Ref(path, @provisionalPoint)
#     @provisionalPoint = null
#     @provisionalLine = null

#   pointerLeave: (e) ->
#     return unless @provisionalPoint
#     @editor.removeObject(@provisionalPoint)
#     @editor.removeObject(@provisionalLine) if @provisionalLine
#     @provisionalPoint = null
#     @provisionalLine = null

#   snapRef: (e) ->
#     @editor.findSnapRef(e, [@provisionalPoint])



# class EditorTool.RotationWreath
#   constructor: (@editor) ->
#     @provisionalPoint = null
#     @provisionalRotationWreath = null

#   pointerDown: (e) ->

#   pointerMove: (e) ->
#     if !@provisionalPoint
#       @provisionalPoint = new Model.Point(new Geo.Point(0, 0))
#       @editor.contextWreath.objects.push(@provisionalPoint)
#       @provisionalRotationWreath = new Model.RotationWreath()

#     workspacePosition = @editor.workspacePosition(e)
#     @provisionalPoint.point = workspacePosition

#   pointerUp: (e) ->
#     return unless @provisionalPoint
#     @provisionalPoint = null

#   pointerLeave: (e) ->
#     return unless @provisionalPoint
#     @editor.removeObject(@provisionalPoint)
#     @provisionalPoint = null
