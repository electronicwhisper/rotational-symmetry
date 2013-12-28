Geo = {}


class Geo.Point
  constructor: (@x, @y) ->


class Geo.Line
  constructor: (@start, @end) ->




intersectionPointForLines = (p1, p2, p3, p4) ->
  # http://paulbourke.net/geometry/pointlineplane/

  return undefined if p1.x == p2.x && p1.y == p2.y
  return undefined if p3.x == p4.x && p3.y == p3.y

  d = (p4.y - p3.y) * (p2.x - p1.x) - (p4.x - p3.x) * (p2.y - p1.y)

  na = (p4.x - p3.x) * (p1.y - p3.y) - (p4.y - p3.y) * (p1.x - p3.x)
  nb = (p2.x - p1.x) * (p1.y - p3.y) - (p2.y - p1.y) * (p1.x - p3.x)

  return undefined if na == 0 && nb == 0 && d == 0 # lines are coincident
  return undefined if d == 0 # lines are parallel

  ua = na / d
  ub = nb / d

  x = p1.x + ua * (p2.x - p1.x)
  y = p1.y + ua * (p2.y - p1.y)

  return new Geo.Point(x, y)


closestPointOnLineForPoint = (p1, p2, p3) ->
  # http://paulbourke.net/geometry/pointlineplane/
  # finds p, the closest point to p3 that lies on line from p1 to p2

  return undefined if p1.x == p2.x && p1.y == p2.y

  d = quadranceFromPointToPoint(p1, p2)
  n = (p3.x - p1.x) * (p2.x - p1.x) + (p3.y - p1.y) * (p2.y - p1.y)

  u = n / d

  x = p1.x + u * (p2.x - p1.x)
  y = p1.y + u * (p2.y - p1.y)

  return new Geo.Point(x, y)


quadranceFromPointToPoint = (p1, p2) ->
  dx = p2.x - p1.x
  dy = p2.y - p1.y
  return dx*dx + dy*dy


reflectionOnLineForPoint = (p1, p2, p3) ->
  p = closestPointOnLineForPoint(p1, p2, p3)
  return undefined unless p

  dx = p3.x - p.x
  dy = p3.y - p.y

  x = p.x - dx
  y = p.y - dy

  return new Geo.Point(x, y)


