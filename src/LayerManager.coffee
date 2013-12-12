class LayerManager

  constructor: (@model) ->
    @layersEl = document.querySelector("#layers")
    @updateDOM()


  updateDOM: ->
    @layersEl.innerHTML = @childrenToHTML(@model)


  objectToHTML: (object) ->
    """
      <div class="layer">
        <div class="layer-main">#{object.name}</div>
        <div class="layer-children">#{@childrenToHTML(object)}</div>
      </div>
    """

  childrenToHTML: (object) ->
    childrenHTML = ""
    if object instanceof Model.Wreath
      for childObject in object.objects
        childrenHTML += @objectToHTML(childObject)
    return childrenHTML