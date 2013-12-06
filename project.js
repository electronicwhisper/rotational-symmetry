// Generated by CoffeeScript 1.6.3
(function() {
  var App, Canvas, Editor, Geo, Group, Model, _base, _ref, _ref1,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.App = App = (function() {
    function App() {
      new Editor();
    }

    return App;

  })();

  Canvas = (function() {
    function Canvas(el) {
      this.el = el;
      this.ctx = this.el.getContext("2d");
      this.setupSize();
    }

    Canvas.prototype.width = function() {
      return this.el.width;
    };

    Canvas.prototype.height = function() {
      return this.el.height;
    };

    Canvas.prototype.setupSize = function() {
      var rect;
      rect = this.el.getBoundingClientRect();
      this.el.width = rect.width;
      return this.el.height = rect.height;
    };

    Canvas.prototype.browserToCanvas = function(browserPoint) {
      var canvasPoint, rect, x, y;
      rect = this.el.getBoundingClientRect();
      x = browserPoint.x - rect.left;
      y = browserPoint.y - rect.top;
      return canvasPoint = new Geo.Point(x, y);
    };

    Canvas.prototype.browserToWorkspace = function(browserPoint) {
      var canvasPoint, workspacePoint;
      canvasPoint = this.browserToCanvas(browserPoint);
      return workspacePoint = this.canvasToWorkspace(canvasPoint);
    };

    Canvas.prototype.canvasToWorkspace = function(canvasPoint) {
      var workspacePoint, x, y;
      x = canvasPoint.x - this.width() / 2;
      y = canvasPoint.y - this.height() / 2;
      return workspacePoint = new Geo.Point(x, y);
    };

    Canvas.prototype.workspaceToCanvas = function(workspacePoint) {
      var canvasPoint, x, y;
      x = workspacePoint.x + this.width() / 2;
      y = workspacePoint.y + this.height() / 2;
      return canvasPoint = new Geo.Point(x, y);
    };

    Canvas.prototype.clear = function() {
      return this.ctx.clearRect(0, 0, this.width(), this.height());
    };

    Canvas.prototype.drawAxes = function() {
      this.ctx.beginPath();
      this.ctx.moveTo(this.width() / 2, 0);
      this.ctx.lineTo(this.width() / 2, this.height());
      this.ctx.strokeStyle = "#ccc";
      this.ctx.lineWidth = 1;
      this.ctx.stroke();
      this.ctx.beginPath();
      this.ctx.moveTo(0, this.height() / 2);
      this.ctx.lineTo(this.width(), this.height() / 2);
      return this.ctx.stroke();
    };

    Canvas.prototype.draw = function(object) {
      if (object instanceof Geo.Point) {
        return this.drawPoint(object);
      } else if (object instanceof Geo.Line) {
        return this.drawLine(object);
      }
    };

    Canvas.prototype.drawPoint = function(point) {
      point = this.workspaceToCanvas(point);
      this.ctx.beginPath();
      this.ctx.arc(point.x, point.y, 3.5, 0, Math.PI * 2);
      this.ctx.fillStyle = "#000";
      return this.ctx.fill();
    };

    Canvas.prototype.drawLine = function(line) {
      var end, start;
      start = this.workspaceToCanvas(line.start);
      end = this.workspaceToCanvas(line.end);
      this.ctx.beginPath();
      this.ctx.moveTo(start.x, start.y);
      this.ctx.lineTo(end.x, end.y);
      this.ctx.strokeStyle = "#000";
      this.ctx.lineWidth = 1;
      return this.ctx.stroke();
    };

    return Canvas;

  })();

  Editor = (function() {
    function Editor() {
      this.canvasPointerUp = __bind(this.canvasPointerUp, this);
      this.canvasPointerMove = __bind(this.canvasPointerMove, this);
      this.canvasPointerDown = __bind(this.canvasPointerDown, this);
      this.canvasPointerLeave = __bind(this.canvasPointerLeave, this);
      this.canvasPointerEnter = __bind(this.canvasPointerEnter, this);
      this.resize = __bind(this.resize, this);
      this.palettePointerDown = __bind(this.palettePointerDown, this);
      this.tool = "select";
      this.context = null;
      this.moving = null;
      this.setupModel();
      this.setupPalette();
      this.setupCanvas();
    }

    Editor.prototype.setupModel = function() {
      var center, centerAddress;
      center = new Model.Point(new Geo.Point(0, 0));
      centerAddress = new Model.Address(new Model.Path(), center);
      this.model = new Model.RotationWreath(centerAddress, 9);
      return this.context = this.model;
    };

    Editor.prototype.setupPalette = function() {
      var canvasEl, palette, tool, toolEl, _i, _len, _ref;
      palette = document.querySelector("#palette");
      _ref = palette.querySelectorAll(".palette-tool");
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        toolEl = _ref[_i];
        tool = toolEl.getAttribute("data-tool");
        canvasEl = toolEl.querySelector("canvas");
        this.drawPaletteTool(tool, canvasEl);
      }
      return palette.addEventListener("pointerdown", this.palettePointerDown);
    };

    Editor.prototype.drawPaletteTool = function(tool, canvasEl) {
      var canvas, l, p1, p2;
      canvas = new Canvas(canvasEl);
      if (tool === "select") {

      } else if (tool === "point") {
        return canvas.draw(new Geo.Point(0, 0));
      } else if (tool === "lineSegment") {
        p1 = new Geo.Point(-10, -10);
        p2 = new Geo.Point(10, 10);
        l = new Geo.Line(p1, p2);
        canvas.draw(p1);
        canvas.draw(p2);
        return canvas.draw(l);
      }
    };

    Editor.prototype.palettePointerDown = function(e) {
      var tool, toolEl;
      toolEl = e.target.closest(".palette-tool");
      if (toolEl == null) {
        return;
      }
      tool = toolEl.getAttribute("data-tool");
      return this.selectTool(tool);
    };

    Editor.prototype.selectTool = function(tool) {
      var palette, toolEl, _i, _len, _ref;
      this.tool = tool;
      palette = document.querySelector("#palette");
      _ref = palette.querySelectorAll(".palette-tool");
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        toolEl = _ref[_i];
        toolEl.removeAttribute("data-selected");
      }
      toolEl = palette.querySelector(".palette-tool[data-tool='" + tool + "']");
      return toolEl.setAttribute("data-selected", "");
    };

    Editor.prototype.setupCanvas = function() {
      var canvasEl;
      canvasEl = document.getElementById("c");
      this.canvas = new Canvas(canvasEl);
      window.addEventListener("resize", this.resize);
      this.resize();
      canvasEl.addEventListener("pointerenter", this.canvasPointerEnter);
      canvasEl.addEventListener("pointerleave", this.canvasPointerLeave);
      canvasEl.addEventListener("pointerdown", this.canvasPointerDown);
      canvasEl.addEventListener("pointermove", this.canvasPointerMove);
      return canvasEl.addEventListener("pointerup", this.canvasPointerUp);
    };

    Editor.prototype.resize = function() {
      this.canvas.setupSize();
      return this.draw();
    };

    Editor.prototype.canvasPointerEnter = function(e) {
      if (this.tool === "point") {
        if (!this.moving) {
          this.moving = new Model.Point(new Geo.Point(0, 0));
          this.context.objects.push(this.moving);
        }
      }
      return this.draw();
    };

    Editor.prototype.canvasPointerLeave = function(e) {
      if (this.tool === "point") {
        if (this.moving) {
          this.context.objects = _.without(this.context.objects, this.moving);
          this.moving = null;
        }
      }
      return this.draw();
    };

    Editor.prototype.canvasPointerDown = function(e) {};

    Editor.prototype.canvasPointerMove = function(e) {
      var pointerPosition, workspacePosition;
      if (this.tool === "point") {
        if (this.moving) {
          pointerPosition = new Geo.Point(e.clientX, e.clientY);
          workspacePosition = this.canvas.browserToWorkspace(pointerPosition);
          this.moving.point = workspacePosition;
        }
      }
      return this.draw();
    };

    Editor.prototype.canvasPointerUp = function(e) {
      if (this.tool === "point") {
        this.moving = null;
      }
      return this.draw();
    };

    Editor.prototype.draw = function() {
      var address, addresses, object, _i, _len, _results;
      this.canvas.clear();
      this.canvas.drawAxes();
      addresses = this.model.addresses();
      _results = [];
      for (_i = 0, _len = addresses.length; _i < _len; _i++) {
        address = addresses[_i];
        object = address.evaluate();
        _results.push(this.canvas.draw(object));
      }
      return _results;
    };

    return Editor;

  })();

  Geo = {};

  Geo.Point = (function() {
    function Point(x, y) {
      this.x = x;
      this.y = y;
    }

    return Point;

  })();

  Geo.Line = (function() {
    function Line(start, end) {
      this.start = start;
      this.end = end;
    }

    return Line;

  })();

  Group = (function() {
    function Group(n) {
      this.n = n;
    }

    Group.prototype.apply = function(op, point) {
      var angle;
      angle = 2 * Math.PI * (op / this.n);
      return this.rotate_(angle, point);
    };

    Group.prototype.invert = function(op) {
      return -op;
    };

    Group.prototype.ops = function() {
      var _i, _ref, _results;
      return (function() {
        _results = [];
        for (var _i = 0, _ref = this.n; 0 <= _ref ? _i < _ref : _i > _ref; 0 <= _ref ? _i++ : _i--){ _results.push(_i); }
        return _results;
      }).apply(this);
    };

    Group.prototype.rotate_ = function(angle, point) {
      var x, y;
      x = Math.cos(angle) * point.x - Math.sin(angle) * point.y;
      y = Math.sin(angle) * point.x + Math.cos(angle) * point.y;
      return new Geo.Point(x, y);
    };

    return Group;

  })();

  Model = {};

  Model.Point = (function() {
    function Point(point) {
      this.point = point;
    }

    return Point;

  })();

  Model.Line = (function() {
    function Line(start, end) {
      this.start = start;
      this.end = end;
    }

    return Line;

  })();

  Model.Wreath = (function() {
    function Wreath() {
      this.objects = [];
    }

    Wreath.prototype.ops = function() {
      throw new Error("Not implemented.");
    };

    Wreath.prototype.inverse = function(op) {
      throw new Error("Not implemented.");
    };

    Wreath.prototype.perform = function(op, point) {
      throw new Error("Not implemented.");
    };

    Wreath.prototype.addresses = function() {
      var address, object, op, path, result, _i, _j, _len, _len1, _ref, _ref1;
      result = [];
      _ref = this.ops();
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        op = _ref[_i];
        _ref1 = this.objects;
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          object = _ref1[_j];
          if (object instanceof Model.Wreath) {
            "TODO";
          } else {
            path = new Model.Path([
              {
                wreath: this,
                op: op
              }
            ]);
            address = new Model.Address(path, object);
            result.push(address);
          }
        }
      }
      return result;
    };

    return Wreath;

  })();

  Model.IdentityWreath = (function(_super) {
    __extends(IdentityWreath, _super);

    function IdentityWreath() {
      IdentityWreath.__super__.constructor.call(this);
    }

    IdentityWreath.prototype.ops = function() {
      return [0];
    };

    IdentityWreath.prototype.inverse = function(op) {
      return op;
    };

    IdentityWreath.prototype.perform = function(op, point) {
      return point;
    };

    return IdentityWreath;

  })(Model.Wreath);

  Model.RotationWreath = (function(_super) {
    __extends(RotationWreath, _super);

    function RotationWreath(center, n) {
      this.center = center;
      this.n = n;
      RotationWreath.__super__.constructor.call(this);
    }

    RotationWreath.prototype.ops = function() {
      var _i, _ref, _results;
      return (function() {
        _results = [];
        for (var _i = 0, _ref = this.n; 0 <= _ref ? _i < _ref : _i > _ref; 0 <= _ref ? _i++ : _i--){ _results.push(_i); }
        return _results;
      }).apply(this);
    };

    RotationWreath.prototype.inverse = function(op) {
      return -op;
    };

    RotationWreath.prototype.perform = function(op, point) {
      var angle, centerPoint, v;
      angle = (op / this.n) * 2 * Math.PI;
      centerPoint = this.center.evaluate();
      v = new Geo.Point(point.x - centerPoint.x, point.y - centerPoint.y);
      v = this.rotate_(angle, v);
      point = new Geo.Point(centerPoint.x + v.x, centerPoint.y + v.y);
      return point;
    };

    RotationWreath.prototype.rotate_ = function(angle, point) {
      var x, y;
      x = Math.cos(angle) * point.x - Math.sin(angle) * point.y;
      y = Math.sin(angle) * point.x + Math.cos(angle) * point.y;
      return new Geo.Point(x, y);
    };

    return RotationWreath;

  })(Model.Wreath);

  Model.Path = (function() {
    function Path(steps) {
      this.steps = steps != null ? steps : [];
    }

    Path.prototype.globalToLocal = function(point) {
      var inverseOp, op, step, wreath, _i, _len, _ref;
      _ref = this.steps;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        step = _ref[_i];
        wreath = step.wreath, op = step.op;
        inverseOp = wreath.inverse(op);
        point = wreath.perform(inverseOp, point);
      }
      return point;
    };

    Path.prototype.localToGlobal = function(point) {
      var op, step, wreath, _i, _len, _ref;
      _ref = this.steps.slice().reverse();
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        step = _ref[_i];
        wreath = step.wreath, op = step.op;
        point = wreath.perform(op, point);
      }
      return point;
    };

    return Path;

  })();

  Model.Address = (function() {
    function Address(path, object) {
      this.path = path;
      this.object = object;
    }

    Address.prototype.evaluate = function() {
      var end, point, start;
      if (this.object instanceof Model.Point) {
        point = this.object.point;
        return this.path.localToGlobal(point);
      } else if (this.object instanceof Model.Line) {
        start = this.object.start.evaluate();
        end = this.object.end.evaluate();
        return new Geo.Line(start, end);
      }
    };

    return Address;

  })();

  if ((_base = Element.prototype).matches == null) {
    _base.matches = (_ref = (_ref1 = Element.prototype.webkitMatchesSelector) != null ? _ref1 : Element.prototype.mozMatchesSelector) != null ? _ref : Element.prototype.oMatchesSelector;
  }

  Element.prototype.closest = function(selector) {
    var fn, parent;
    if (_.isString(selector)) {
      fn = function(el) {
        return el.matches(selector);
      };
    } else {
      fn = selector;
    }
    if (fn(this)) {
      return this;
    } else {
      parent = this.parentNode;
      if (parent != null) {
        return parent.closest(fn);
      } else {
        return void 0;
      }
    }
  };

}).call(this);
