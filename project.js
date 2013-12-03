// Generated by CoffeeScript 1.6.3
(function() {
  var App, Canvas, Group, Line, LineRef, Model, Point, PointRef, Wreath,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.App = App = (function() {
    function App() {
      this.mouseup_ = __bind(this.mouseup_, this);
      this.mousemove_ = __bind(this.mousemove_, this);
      this.resize_ = __bind(this.resize_, this);
      var el;
      el = document.getElementById("c");
      this.canvas = new Canvas(el);
      this.model = new Model();
      this.model.points.push(new Point(0, 0));
      window.addEventListener("resize", this.resize_);
      document.addEventListener("mousemove", this.mousemove_);
      document.addEventListener("mouseup", this.mouseup_);
      this.resize_();
    }

    App.prototype.resize_ = function() {
      this.canvas.el.width = document.body.clientWidth;
      return this.canvas.el.height = document.body.clientHeight;
    };

    App.prototype.mousemove_ = function(e) {
      var mousePosition, point;
      mousePosition = new Point(e.clientX, e.clientY);
      point = this.canvas.canvasToWorkspace(mousePosition);
      _.last(this.model.points).setToPoint(point);
      this.canvas.clear();
      return this.model.draw(this.canvas);
    };

    App.prototype.mouseup_ = function(e) {
      var mousePosition, point, startPoint;
      mousePosition = new Point(e.clientX, e.clientY);
      point = this.canvas.canvasToWorkspace(mousePosition);
      startPoint = _.last(this.model.points);
      this.model.points.push(point);
      return this.model.lines.push({
        start: {
          point: startPoint,
          op: 0
        },
        end: {
          point: point,
          op: 0
        }
      });
    };

    return App;

  })();

  Canvas = (function() {
    function Canvas(el) {
      this.el = el;
      this.ctx = this.el.getContext("2d");
    }

    Canvas.prototype.width = function() {
      return this.el.width;
    };

    Canvas.prototype.height = function() {
      return this.el.height;
    };

    Canvas.prototype.canvasToWorkspace = function(canvasPoint) {
      var workspacePoint, x, y;
      x = canvasPoint.x - this.width() / 2;
      y = canvasPoint.y - this.height() / 2;
      return workspacePoint = new Point(x, y);
    };

    Canvas.prototype.workspaceToCanvas = function(workspacePoint) {
      var canvasPoint, x, y;
      x = workspacePoint.x + this.width() / 2;
      y = workspacePoint.y + this.height() / 2;
      return canvasPoint = new Point(x, y);
    };

    Canvas.prototype.clear = function() {
      return this.ctx.clearRect(0, 0, this.width(), this.height());
    };

    return Canvas;

  })();

  Group = (function() {
    function Group(n) {
      this.n = n;
    }

    Group.prototype.derive = function(point, op) {
      var angle;
      angle = 2 * Math.PI * (op / this.n);
      return this.rotate_(point, angle);
    };

    Group.prototype.invert = function(point, op) {
      return this.derive(point, -op);
    };

    Group.prototype.ops = function() {
      var _i, _ref, _results;
      return (function() {
        _results = [];
        for (var _i = 0, _ref = this.n; 0 <= _ref ? _i < _ref : _i > _ref; 0 <= _ref ? _i++ : _i--){ _results.push(_i); }
        return _results;
      }).apply(this);
    };

    Group.prototype.rotate_ = function(point, angle) {
      var x, y;
      x = Math.cos(angle) * point.x - Math.sin(angle) * point.y;
      y = Math.sin(angle) * point.x + Math.cos(angle) * point.y;
      return new Point(x, y);
    };

    return Group;

  })();

  Line = (function() {
    function Line(start, end) {
      this.start = start;
      this.end = end;
    }

    Line.prototype.draw = function(canvas) {
      var canvasEnd, canvasStart, ctx;
      canvasStart = canvas.workspaceToCanvas(this.start);
      canvasEnd = canvas.workspaceToCanvas(this.end);
      ctx = canvas.ctx;
      ctx.beginPath();
      ctx.moveTo(canvasStart.x, canvasStart.y);
      ctx.lineTo(canvasEnd.x, canvasEnd.y);
      ctx.lineWidth = 1;
      ctx.strokeStyle = "#000";
      return ctx.stroke();
    };

    return Line;

  })();

  Model = (function() {
    function Model() {
      this.group = new Group(12);
      this.points = [];
      this.lines = [];
    }

    Model.prototype.draw = function(canvas) {
      var derivedPoint, end, l, line, op, point, start, _i, _j, _len, _len1, _ref, _ref1, _results;
      _ref = this.group.ops();
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        op = _ref[_i];
        _ref1 = this.points;
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          point = _ref1[_j];
          derivedPoint = this.group.derive(point, op);
          derivedPoint.draw(canvas);
        }
        _results.push((function() {
          var _k, _len2, _ref2, _results1;
          _ref2 = this.lines;
          _results1 = [];
          for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
            line = _ref2[_k];
            start = line.start.point;
            start = this.group.derive(start, line.start.op);
            start = this.group.derive(start, op);
            end = line.end.point;
            end = this.group.derive(end, line.end.op);
            end = this.group.derive(end, op);
            l = new Line(start, end);
            _results1.push(l.draw(canvas));
          }
          return _results1;
        }).call(this));
      }
      return _results;
    };

    return Model;

  })();

  Point = (function() {
    Point.prototype.size = 4;

    function Point(x, y) {
      this.x = x;
      this.y = y;
    }

    Point.prototype.setToPoint = function(point) {
      this.x = point.x;
      return this.y = point.y;
    };

    Point.prototype.draw = function(canvas) {
      var ctx;
      this.path_(canvas);
      ctx = canvas.ctx;
      ctx.fillStyle = "#000";
      return ctx.fill();
    };

    Point.prototype.test = function(canvas, canvasPoint) {
      var ctx;
      this.path_(canvas);
      ctx = canvas.ctx;
      return ctx.isPointInPath(canvasPoint.x, canvasPoint.y);
    };

    Point.prototype.path_ = function(canvas) {
      var canvasPoint, ctx;
      canvasPoint = canvas.workspaceToCanvas(this);
      ctx = canvas.ctx;
      ctx.beginPath();
      return ctx.arc(canvasPoint.x, canvasPoint.y, this.size, 0, Math.PI * 2);
    };

    return Point;

  })();

  /*
  
  PointRef
    path: [{wreath, op}]
    point:
  */


  PointRef = (function() {
    function PointRef(point, path) {
      this.point = point;
      this.path = path != null ? path : [];
    }

    PointRef.prototype.evaluate = function() {
      var op, point, step, wreath, _i, _len, _ref;
      point = this.point;
      _ref = this.path;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        step = _ref[_i];
        wreath = step.wreath;
        op = step.op;
        point = wreath.control.derive(point, op);
      }
      return point;
    };

    return PointRef;

  })();

  LineRef = (function() {
    function LineRef(start, end) {
      this.start = start;
      this.end = end;
    }

    LineRef.prototype.evaluate = function() {
      var end, start;
      start = this.start.evaluate();
      end = this.end.evaluate();
      return new Line(start, end);
    };

    return LineRef;

  })();

  Wreath = (function() {
    function Wreath(control, fibers) {
      this.control = control;
      this.fibers = fibers != null ? fibers : [];
    }

    Wreath.prototype.draw = function(canvas) {
      var fiber, op, transformedFiber, _i, _len, _ref, _results;
      _ref = this.control.ops();
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        op = _ref[_i];
        _results.push((function() {
          var _j, _len1, _ref1, _results1;
          _ref1 = this.fibers;
          _results1 = [];
          for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
            fiber = _ref1[_j];
            transformedFiber = fiber.transform(this.control, op);
            _results1.push(transformedFiber.draw());
          }
          return _results1;
        }).call(this));
      }
      return _results;
    };

    return Wreath;

  })();

}).call(this);
