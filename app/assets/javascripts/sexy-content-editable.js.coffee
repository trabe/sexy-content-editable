#= require_tree
#= require bootstrap
SelectionManager = do ->
  selection = null
  range     = null

  stripTags = ->
    text = range.toString()
    range.deleteContents()
    range.insertNode(document.createTextNode(text))

  select = (node) ->
    selection = document.getSelection()
    selection.removeAllRanges()

    range = document.createRange()
    range.selectNode(node)

    selection.addRange(range)

  record = ->
    selection = document.getSelection()
    if selection.rangeCount > 0
      range     = selection.getRangeAt(0)

  restore = ->
    selection.removeAllRanges()
    selection.addRange(range)

  collapse = ->
    range.collapse()
    restore()

  collapse  : collapse
  select    : select
  record    : record
  restore   : restore
  stripTags : stripTags


class BasePrompt
  constructor : (tmpl) ->
    @template = JST[tmpl]

  show : (options = {}) ->
    SelectionManager.record()

    $modal = $(@template())
    $('body').append($modal)
    $modal.modal(show: false)

    $modal.on 'hidden.bs.modal', ->
      SelectionManager.collapse()
      $modal.remove()

    $modal.on 'submit', 'form', (e) =>
      e.preventDefault()
      $form = $(e.currentTarget)
      @_processUserInput($form.serializeArray())
      $modal.modal('hide')

    @_beforeShow($modal, options)
    @_installAdditionalHandlers($modal)

    $modal.modal('show')

  _beforeShow : -> #NOOP
  _installAdditionalHandlers : -> #NOOP

class LinkPrompt extends BasePrompt
  constructor: ->
    super('templates/link_prompt_modal')

  _processUserInput : (userInput) =>
    url = userInput.filter (e) ->
      e.value if e.name is "url"

    SelectionManager.restore()
    document.execCommand('CreateLink', null, url[0].value)

  _beforeShow : ($modal, options) ->
    $modal.find('[name=url]').val(options.url)

  _installAdditionalHandlers : ($modal) ->
    $modal.on 'click', '[data-behaviour=editor-remove-link]', ->
      SelectionManager.stripTags()


class HtmlPrompt extends BasePrompt
  constructor: ->
    super('templates/html_prompt_modal')

  _processUserInput : (userInput) =>
    html = userInput.filter (e) ->
      e.value if e.name is "html"


    SelectionManager.restore()
    document.execCommand('InsertHTML', null, html[0].value)


# NOTE: Extensive docs for executeCommand method at
# https://developer.mozilla.org/en-US/docs/Rich-Text_Editing_in_Mozilla#Executing_Commands
#
# Sexy content editable API: invoke the API methods using jQuery style shit. E.g:
#
#     $el.sexyContentEditable()
#     ...
#     $el.sexyContentEditable('setContent', 'my new content')
#     $el.sexyContentEditable('appendContent', 'content to append')
#
class SexyContentEditable

  ALL_BUTTONS = [ # All buttons
    'undo', 'redo', 'clean', 'b', 'i', 'sub', 'sup', 'ul', 'ol', 'ltab', 'rtab', 'h1', 'h2', 'h3', 'h4', 'h5', 'p', 'prompt-link', 'prompt-html'
  ]

  constructor: (@$formElement) ->
    @_extractConfiguration()
    @_buildComponent()
    @_bindEvents()

  _extractConfiguration: ->
    @value         = @$formElement.attr('value')
    # TODO: Not in use. Fix this ¬_¬U
    @buttonsConfig = @$formElement.data('toolbar-config') || 'default'
    @buttons       = @$formElement.data('toolbar-buttons') || ALL_BUTTONS
    @size          = @$formElement.data('size') || ''

  _buildComponent: ->
    sizeClass = "sexy-content-editable-content-#{@size}"
    @$editor = $(JST["templates/editor"](size: sizeClass))

    @$content = @$editor.find('.sexy-content-editable-content')
    @$toolbar = @$editor.find('.sexy-content-editable-toolbar')

    @$toolbar.find('a').each (_, button) =>
      $button = $(button)
      $button.remove() if $.inArray($button.data('name'), @buttons) == -1

    # Ensure usage of P for when pressing
    document.execCommand('defaultParagraphSeparator', false, 'p')

    @$content.html(@value) if @value

    @$formElement.after(@$editor)
    @$formElement.hide()

    @linkPrompt = new LinkPrompt()
    @htmlPrompt = new HtmlPrompt()


  _bindEvents: ->
    # Toolbar use
    @$toolbar.on 'click', 'a', @_toolbarButtonClickHandler

    # Fake the change event
    @$content.on 'focus', @_contentFocusHandler
    @$content.on 'blur keyup paste', @_contentUpdateHandler

    # Content change
    @$content.on 'change', @_contentChangeHandler

    # Input value change
    @$formElement.on 'change', @_elementChangeHandler

    # Focus management
    @$editor.on 'focusin', @_enableButtons
    @$editor.on 'focusout', @_disableButtons

    # Edit links clicking on them
    @$content.on 'click', 'a', @_editLink


  _toolbarButtonClickHandler: (event) =>
    event.preventDefault()
    $button = $(event.currentTarget)
    role = $button.data('role')
    name = $button.data('name')


    if prompt = name.match /prompt\-(.+)/
      @_showPrompt(prompt[1])
    else if md = role.match /b\-(.+)/
      document.execCommand 'formatBlock', false, md[1]
    else
      document.execCommand role, false, null

    @$content.trigger 'change'


  _contentFocusHandler: (event) =>
    @$content.data 'value', @$content.html()
    @$content


  _contentUpdateHandler: (event) =>
    newHtml = @$content.html()

    if @$content.data('value') isnt newHtml
      # avoid problems with empty tags
      newHtml = '' if @$content.text().trim().length == 0

      @$content.data 'value', newHtml
      @$content.trigger 'change'


  _contentChangeHandler: (event) =>
    @$formElement.attr 'value', @$content.data('value')


  _elementChangeHandler : (event) =>
    value = $(event.currentTarget).val()
    @$content.html(value)


  _enableButtons : =>
    @$toolbar.find('a, button').attr('disabled', null)


  _disableButtons : (event) =>
    if @$editor.has(event.relatedTarget).length == 0
      @$toolbar.find('a, button').attr('disabled', 'disabled')


  _showPrompt : (prompt) ->
    if prompt is 'link'
      @linkPrompt.show()
    else if prompt is 'html'
      @htmlPrompt.show()


  _editLink : (event) =>
    event.preventDefault()
    $link = $(event.currentTarget)
    SelectionManager.select($link.get(0))

    @linkPrompt.show(url: $link.attr('href'))

  #
  # PUBLIC API
  #

  setContent : (value) =>
    @$content.html(value).trigger 'paste'

  appendContent : (value) =>
    oldContent = @$content.html()
    @setContent(oldContent + value)

$.fn.sexyContentEditable = (args...)->
  @.each ->
    $el = $ @
    console.log('ola ke ase')

    unless rte = $el.data('sexyContentEditable')
      rte = new SexyContentEditable($el)
      $el.data 'sexyContentEditable', rte

    if args.length
      method = args.splice(0, 1)[0]
      rte[method].apply(rte, args)


$ ->
  $(document).ajaxComplete ->
    $('[data-behaviour~=sexy-content-editable]').sexyContentEditable()
  $('[data-behaviour~=sexy-content-editable]').sexyContentEditable()

