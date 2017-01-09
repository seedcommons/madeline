class MS.Views.NoteView extends Backbone.View

  initialize: (params) ->
    new MS.Views.AutoLoadingIndicatorView()
    if @newRecord() then @editView() else @showView()

  events:
    'click a.edit-action': 'editView'
    'click .cancel': 'showView'
    'submit .note-form': 'update'
    'ajax:success .delete-action': 'remove'

  newRecord: ->
    @$el.data('id') == 'new'

  editView: (e) ->
    e.preventDefault() if e
    @$('.view-block').hide()
    @$('.form-block').show()
    @resizeTextareas()

  showView: (e) ->
    e.preventDefault() if e
    if @newRecord()
      @$el.remove()
    else
      @$('.view-block').show()
      @$('.form-block').hide()

  update: (e) ->
    $form = @$(e.target).closest('form')
    # We send form data via ajax so we can capture the response from server
    $.post($form.attr('action'), $form.serialize())
      .done (response) =>
        @$('.view-block').html(response)
        @$('.view-block').show()
        @$('.form-block').hide()

    # Prevent form from being submitted again
    return false

  remove: (e) ->
    @$el.hide('fast')

  # Sets textareas to the height of their content, and resizes them dynamically on edit
  resizeTextareas: (e) ->
    $('.note textarea').each ->
      @setAttribute 'style', "height:#{@scrollHeight}px;overflow-y:hidden;"
    .on 'input', ->
      @style.height = 'auto'
      @style.height = @scrollHeight + 'px'
