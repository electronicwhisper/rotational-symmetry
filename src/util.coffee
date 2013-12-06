Element::matches ?= Element::webkitMatchesSelector ? Element::mozMatchesSelector ? Element::oMatchesSelector

Element::closest = (selector) ->
  if _.isString(selector)
    fn = (el) -> el.matches(selector)
  else
    fn = selector

  if fn(this)
    return this
  else
    parent = @parentNode
    if parent?
      return parent.closest(fn)
    else
      return undefined