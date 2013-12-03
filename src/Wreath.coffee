class Wreath
  constructor: (@control, @fibers=[]) ->


  draw: (canvas) ->
    for op in @control.ops()
      for fiber in @fibers
        transformedFiber = fiber.transform(@control, op)
        transformedFiber.draw()




