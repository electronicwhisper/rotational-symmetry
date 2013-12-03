class Model
  constructor: ->
    @group = new Group(12)
    @points = []
    @lines = []

  draw: (canvas) ->
    for op in @group.ops()
      for point in @points
        derivedPoint = @group.derive(point, op)
        derivedPoint.draw(canvas)

      for line in @lines
        start = line.start.point
        start = @group.derive(start, line.start.op)
        start = @group.derive(start, op)
        end = line.end.point
        end = @group.derive(end, line.end.op)
        end = @group.derive(end, op)
        l = new Line(start, end)
        l.draw(canvas)

  test: (canvas, canvasPoint) ->
    for op in @group.ops()
      for point in @points
        derivedPoint = @group.derive(point, op)
        if derivedPoint.test(canvas, canvasPoint)
          return {point, op}