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
      return this.el.width / this.ratio;
    };

    Canvas.prototype.height = function() {
      return this.el.height / this.ratio;
    };

    Canvas.prototype.setupSize = function() {
      var backingStoreRatio, devicePixelRatio, rect;
      devicePixelRatio = window.devicePixelRatio || 1;
      backingStoreRatio = this.ctx.webkitBackingStorePixelRatio || this.ctx.mozBackingStorePixelRatio || this.ctx.msBackingStorePixelRatio || this.ctx.oBackingStorePixelRatio || this.ctx.backingStorePixelRatio || 1;
      this.ratio = devicePixelRatio / backingStoreRatio;
      rect = this.el.getBoundingClientRect();
      this.el.width = rect.width * this.ratio;
      this.el.height = rect.height * this.ratio;
      this.ctx.setTransform(1, 0, 0, 1, 0, 0);
      return this.ctx.scale(this.ratio, this.ratio);
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

    Canvas.prototype.drawObject = function(object) {
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

    Canvas.prototype.isObjectNearPoint = function(object, canvasPoint) {
      if (object instanceof Geo.Point) {
        return this.isPointNearPoint(object, canvasPoint);
      } else if (object instanceof Geo.Line) {
        return this.isLineNearPoint(object, canvasPoint);
      }
    };

    Canvas.prototype.isPointNearPoint = function(point, canvasPoint) {
      var distanceSquared, dx, dy;
      point = this.workspaceToCanvas(point);
      dx = point.x - canvasPoint.x;
      dy = point.y - canvasPoint.y;
      distanceSquared = (dx * dx) + (dy * dy);
      return distanceSquared < 10 * 10;
    };

    Canvas.prototype.isLineNearPoint = function(line, canvasPoint) {
      return false;
    };

    return Canvas;

  })();

  Editor = (function() {
    function Editor() {
      this.canvasPointerLeave = __bind(this.canvasPointerLeave, this);
      this.canvasPointerUp = __bind(this.canvasPointerUp, this);
      this.canvasPointerMove = __bind(this.canvasPointerMove, this);
      this.canvasPointerDown = __bind(this.canvasPointerDown, this);
      this.resize = __bind(this.resize, this);
      this.palettePointerDown = __bind(this.palettePointerDown, this);
      this.tool = new Editor.Select(this);
      this.contextWreath = null;
      this.setupModel();
      this.setupPalette();
      this.setupCanvas();
    }

    Editor.prototype.setupModel = function() {
      var center, centerAddress, rotation;
      this.model = new Model.IdentityWreath();
      center = new Model.Point(new Geo.Point(0, 0));
      this.model.objects.push(center);
      centerAddress = new Model.Address(new Model.Path([
        {
          wreath: this.model,
          op: 0
        }
      ]), center);
      rotation = new Model.RotationWreath(centerAddress, 9);
      this.model.objects.push(rotation);
      return this.contextWreath = rotation;
    };

    Editor.prototype.setupPalette = function() {
      var canvasEl, palette, toolEl, toolName, _i, _len, _ref;
      palette = document.querySelector("#palette");
      _ref = palette.querySelectorAll(".palette-tool");
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        toolEl = _ref[_i];
        toolName = toolEl.getAttribute("data-tool");
        canvasEl = toolEl.querySelector("canvas");
        this.drawPaletteTool(toolName, canvasEl);
      }
      return palette.addEventListener("pointerdown", this.palettePointerDown);
    };

    Editor.prototype.drawPaletteTool = function(toolName, canvasEl) {
      var canvas, l, p1, p2;
      canvas = new Canvas(canvasEl);
      if (toolName === "Select") {

      } else if (toolName === "Point") {
        return canvas.drawPoint(new Geo.Point(0, 0));
      } else if (toolName === "LineSegment") {
        p1 = new Geo.Point(-10, -10);
        p2 = new Geo.Point(10, 10);
        l = new Geo.Line(p1, p2);
        canvas.drawPoint(p1);
        canvas.drawPoint(p2);
        return canvas.drawLine(l);
      }
    };

    Editor.prototype.palettePointerDown = function(e) {
      var toolEl, toolName;
      toolEl = e.target.closest(".palette-tool");
      if (toolEl == null) {
        return;
      }
      toolName = toolEl.getAttribute("data-tool");
      return this.selectTool(toolName);
    };

    Editor.prototype.selectTool = function(toolName) {
      var palette, toolEl, _i, _len, _ref;
      this.tool = new Editor[toolName](this);
      palette = document.querySelector("#palette");
      _ref = palette.querySelectorAll(".palette-tool");
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        toolEl = _ref[_i];
        toolEl.removeAttribute("data-selected");
      }
      toolEl = palette.querySelector(".palette-tool[data-tool='" + toolName + "']");
      return toolEl.setAttribute("data-selected", "");
    };

    Editor.prototype.setupCanvas = function() {
      var canvasEl;
      canvasEl = document.getElementById("c");
      this.canvas = new Canvas(canvasEl);
      window.addEventListener("resize", this.resize);
      this.resize();
      canvasEl.addEventListener("pointerdown", this.canvasPointerDown);
      canvasEl.addEventListener("pointermove", this.canvasPointerMove);
      canvasEl.addEventListener("pointerup", this.canvasPointerUp);
      canvasEl.addEventListener("pointerleave", this.canvasPointerLeave);
      return canvasEl.addEventListener("pointercancel", this.canvasPointerLeave);
    };

    Editor.prototype.resize = function() {
      this.canvas.setupSize();
      return this.draw();
    };

    Editor.prototype.workspacePosition = function(e) {
      var pointerPosition, workspacePosition;
      pointerPosition = new Geo.Point(e.clientX, e.clientY);
      return workspacePosition = this.canvas.browserToWorkspace(pointerPosition);
    };

    Editor.prototype.canvasPointerDown = function(e) {
      this.tool.pointerDown(e);
      return this.draw();
    };

    Editor.prototype.canvasPointerMove = function(e) {
      this.tool.pointerMove(e);
      return this.draw();
    };

    Editor.prototype.canvasPointerUp = function(e) {
      this.tool.pointerUp(e);
      return this.draw();
    };

    Editor.prototype.canvasPointerLeave = function(e) {
      this.tool.pointerLeave(e);
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
        _results.push(this.canvas.drawObject(object));
      }
      return _results;
    };

    Editor.prototype.addressesNearPointer = function(e) {
      var address, addresses, canvasPosition, isNear, object, pointerPosition, result, _i, _len;
      pointerPosition = new Geo.Point(e.clientX, e.clientY);
      canvasPosition = this.canvas.browserToCanvas(pointerPosition);
      result = [];
      addresses = this.model.addresses();
      for (_i = 0, _len = addresses.length; _i < _len; _i++) {
        address = addresses[_i];
        object = address.evaluate();
        isNear = this.canvas.isObjectNearPoint(object, canvasPosition);
        if (isNear) {
          result.push(address);
        }
      }
      return result;
    };

    return Editor;

  })();

  Editor.Select = (function() {
    function Select(editor) {
      this.editor = editor;
      this.selectedAddress = null;
    }

    Select.prototype.pointerDown = function(e) {
      var found;
      found = this.editor.addressesNearPointer(e);
      if (found.length > 0) {
        return this.selectedAddress = found[0];
      } else {
        return this.selectedAddress = null;
      }
    };

    Select.prototype.pointerMove = function(e) {
      var localPoint, workspacePosition;
      if (!this.selectedAddress) {
        return;
      }
      workspacePosition = this.editor.workspacePosition(e);
      localPoint = this.selectedAddress.path.globalToLocal(workspacePosition);
      return this.selectedAddress.object.point = localPoint;
    };

    Select.prototype.pointerUp = function(e) {
      return this.selectedAddress = null;
    };

    Select.prototype.pointerLeave = function(e) {};

    return Select;

  })();

  Editor.Point = (function() {
    function Point(editor) {
      this.editor = editor;
      this.provisionalPoint = null;
    }

    Point.prototype.pointerDown = function(e) {};

    Point.prototype.pointerMove = function(e) {
      var workspacePosition;
      if (!this.provisionalPoint) {
        this.provisionalPoint = new Model.Point(new Geo.Point(0, 0));
        this.editor.contextWreath.objects.push(this.provisionalPoint);
      }
      workspacePosition = this.editor.workspacePosition(e);
      return this.provisionalPoint.point = workspacePosition;
    };

    Point.prototype.pointerUp = function(e) {
      if (!this.provisionalPoint) {
        return;
      }
      return this.provisionalPoint = null;
    };

    Point.prototype.pointerLeave = function(e) {
      var contextWreath;
      if (!this.provisionalPoint) {
        return;
      }
      contextWreath = this.editor.contextWreath;
      contextWreath.objects = _.without(contextWreath.objects, this.provisionalPoint);
      return this.provisionalPoint = null;
    };

    return Point;

  })();

  Editor.LineSegment = (function() {
    function LineSegment(editor) {
      this.editor = editor;
      this.lastPoint = null;
      this.provisionalPoint = null;
      this.provisionalLine = null;
    }

    LineSegment.prototype.pointerDown = function(e) {};

    LineSegment.prototype.pointerMove = function(e) {
      var end, path, start, workspacePosition;
      if (!this.provisionalPoint) {
        this.provisionalPoint = new Model.Point(new Geo.Point(0, 0));
        this.editor.contextWreath.objects.push(this.provisionalPoint);
        if (this.lastPoint) {
          path = new Model.Path([
            {
              wreath: this.editor.contextWreath,
              op: 0
            }
          ]);
          start = new Model.Address(path, this.lastPoint);
          end = new Model.Address(path, this.provisionalPoint);
          this.provisionalLine = new Model.Line(start, end);
          this.editor.contextWreath.objects.push(this.provisionalLine);
        }
      }
      workspacePosition = this.editor.workspacePosition(e);
      return this.provisionalPoint.point = workspacePosition;
    };

    LineSegment.prototype.pointerUp = function(e) {
      if (!this.provisionalPoint) {
        return;
      }
      this.lastPoint = this.provisionalPoint;
      this.provisionalPoint = null;
      return this.provisionalLine = null;
    };

    LineSegment.prototype.pointerLeave = function(e) {
      var contextWreath;
      if (!this.provisionalPoint) {
        return;
      }
      contextWreath = this.editor.contextWreath;
      contextWreath.objects = _.without(contextWreath.objects, this.provisionalPoint, this.provisionalLine);
      this.provisionalPoint = null;
      return this.provisionalLine = null;
    };

    return LineSegment;

  })();

  /*
  
  Concepts:
  
    Moving - point to move with pointermove events
  
    Provisional - geometries which would be deleted on pointerleave
  
  
  makeProvisional
  
  removeProvisional
  
  moveMoving
  
  
  
  Point
    make a point
    *DONE
  
  Line
    make a point
    make a point, make a line from current point to previous point
  */


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
      var address, childAddress, childAddresses, object, op, path, result, _i, _j, _k, _len, _len1, _len2, _ref, _ref1;
      result = [];
      _ref = this.ops();
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        op = _ref[_i];
        _ref1 = this.objects;
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          object = _ref1[_j];
          if (object instanceof Model.Wreath) {
            childAddresses = object.addresses();
            for (_k = 0, _len2 = childAddresses.length; _k < _len2; _k++) {
              childAddress = childAddresses[_k];
              path = childAddress.path.prepend({
                wreath: this,
                op: op
              });
              address = new Model.Address(path, childAddress.object);
              result.push(address);
            }
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

    Path.prototype.prepend = function(step) {
      return new Model.Path([step].concat(this.steps));
    };

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
        start = this.path.localToGlobal(this.object.start.evaluate());
        end = this.path.localToGlobal(this.object.end.evaluate());
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
      if ((parent != null) && parent.nodeType === Node.ELEMENT_NODE) {
        return parent.closest(fn);
      } else {
        return void 0;
      }
    }
  };

}).call(this);
