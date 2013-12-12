class LayerManager

  constructor: ->
    @layersEl = document.querySelector("#layers")


  writeModelToDOM: (model) ->
    @layersEl.innerHTML = ""
    els = @childrenToEls(model)
    @layersEl.appendChild(els)


  objectToEl: (object) ->
    html = """
      <div class="layer">
        <div class="layer-main">#{object.name}</div>
        <div class="layer-children"></div>
      </div>
    """
    el = makeElFromHTML(html)
    el.querySelector(".layer-children").appendChild(@childrenToEls(object))

  childrenToEls: (object) ->
    els = document.createDocumentFragment()
    if object instanceof Model.Wreath
      for childObject in object.objects
        childEl = @objectToEl(childObject)
        els.appendChild(childEl)
    return els