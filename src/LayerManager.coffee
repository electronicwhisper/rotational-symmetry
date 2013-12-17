class LayerManager

  constructor: (@editor) ->
    @layersEl = document.querySelector("#layers")
    @domToModel_ = new WeakMap()
    @modelToDom_ = new WeakMap()

    @layersEl.addEventListener("pointerdown", @pointerdown)


  reset: ->
    @domToModel_ = new WeakMap()
    @modelToDom_ = new WeakMap()
    @layersEl.innerHTML = ""


  pointerdown: (e) =>
    target = e.target
    until object = @domToModel_.get(target)
      target = target.parentNode

    if object instanceof Model.Wreath
      @editor.contextWreath = object
      @editor.refresh()


  writeToDOM: () ->
    @reset()

    model = @editor.model
    contextWreath = @editor.contextWreath

    rootEl = @objectToEl(model)
    @layersEl.appendChild(rootEl)

    contextEl = @modelToDom_.get(contextWreath)
    contextEl.classList.add("context")


  objectToEl: (object) ->
    html = """
      <div class="layer">
        <div class="layer-main">#{object.name}</div>
        <div class="layer-children"></div>
      </div>
    """
    el = makeElFromHTML(html)
    el.querySelector(".layer-children").appendChild(@childrenToEls(object))

    @domToModel_.set(el, object)
    @modelToDom_.set(object, el)

    return el

  childrenToEls: (object) ->
    els = document.createDocumentFragment()
    if object instanceof Model.Wreath
      for childObject in object.objects
        childEl = @objectToEl(childObject)
        els.appendChild(childEl)
    return els