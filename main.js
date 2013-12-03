// Generated by CoffeeScript 1.6.3
(function() {
  var canvasToWorkspace, ctx, draw, drawLine, drawPoint, height, mousePosition, n, pointermove, pointerup, points, resize, rotate, setup, width, workspaceToCanvas;

  mousePosition = [0, 0];

  ctx = null;

  width = null;

  height = null;

  setup = function() {
    resize();
    window.addEventListener("resize", resize);
    document.addEventListener("pointermove", pointermove);
    return document.addEventListener("pointerup", pointerup);
  };

  resize = function() {
    var canvas;
    canvas = document.querySelector("#c");
    width = canvas.width = document.body.clientWidth;
    height = canvas.height = document.body.clientHeight;
    return ctx = canvas.getContext("2d");
  };

  canvasToWorkspace = function(canvasPoint) {
    var workspacePoint;
    return workspacePoint = [canvasPoint[0] - width / 2, canvasPoint[1] - height / 2];
  };

  workspaceToCanvas = function(workspacePoint) {
    var canvasPoint;
    return canvasPoint = [workspacePoint[0] + width / 2, workspacePoint[1] + height / 2];
  };

  rotate = function(angle, point) {
    return [Math.cos(angle) * point[0] - Math.sin(angle) * point[1], Math.sin(angle) * point[0] + Math.cos(angle) * point[1]];
  };

  n = 12;

  points = [[0, 0]];

  draw = function() {
    var i, point, pointNum, previousPoint, rotatedPoint, rotatedPreviousPoint, _i, _results;
    ctx.fillStyle = "#000";
    ctx.strokeStyle = "#000";
    ctx.lineWidth = 1;
    ctx.clearRect(0, 0, width, height);
    points[points.length - 1] = canvasToWorkspace(mousePosition);
    _results = [];
    for (i = _i = 0; 0 <= n ? _i < n : _i > n; i = 0 <= n ? ++_i : --_i) {
      _results.push((function() {
        var _j, _len, _results1;
        _results1 = [];
        for (pointNum = _j = 0, _len = points.length; _j < _len; pointNum = ++_j) {
          point = points[pointNum];
          rotatedPoint = rotate(Math.PI * 2 * i / n, point);
          drawPoint(rotatedPoint);
          if (pointNum > 0) {
            previousPoint = points[pointNum - 1];
            rotatedPreviousPoint = rotate(Math.PI * 2 * i / n, previousPoint);
            _results1.push(drawLine(rotatedPoint, rotatedPreviousPoint));
          } else {
            _results1.push(void 0);
          }
        }
        return _results1;
      })());
    }
    return _results;
  };

  pointermove = function(e) {
    mousePosition = [e.clientX, e.clientY];
    return draw();
  };

  pointerup = function(e) {
    var point;
    point = canvasToWorkspace(mousePosition);
    points.push(point);
    return draw();
  };

  drawPoint = function(point) {
    point = workspaceToCanvas(point);
    ctx.beginPath();
    ctx.arc(point[0], point[1], 4.5, 0, Math.PI * 2);
    return ctx.fill();
  };

  drawLine = function(point1, point2) {
    point1 = workspaceToCanvas(point1);
    point2 = workspaceToCanvas(point2);
    ctx.beginPath();
    ctx.moveTo.apply(ctx, point1);
    ctx.lineTo.apply(ctx, point2);
    return ctx.stroke();
  };

  setup();

}).call(this);
