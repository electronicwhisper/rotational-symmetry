class Model
  constructor: ->
    @group = new Group(12)
    @points = []
    @lines = []

  draw: (canvas) ->
    for point in @points
      derivedPoints = @group.deriveAll(point)
      for derivedPoint in derivedPoints
        derivedPoint.draw(canvas)



###

Derived point
  original: Point

  need a way to convert original to derived and back


Group
  Points
  Lines which reference Points and derived Points




Group
  points: {Id: Point}
  lines: [{
    start: {original: Id, op: Number}
    end: {original: Id, op: Number}
  }]




###