class MS.Views.NoteView extends Backbone.View

  initialize: (params) ->
    new MS.Views.AutoLoadingIndicatorView()
    @showView() unless @$el.data('id') == 'new'

  events:
    'click a.edit-action': 'editView'
    'click .cancel': 'showView'
    'submit .edit-form': 'update'
    'submit .new-form': 'create'

  editView: (e) ->
    e.preventDefault()
    @$('.view-block').hide()
    @$('.form-block').show()

  showView: (e) ->
    e.preventDefault() if e
    @$('.view-block').show()
    @$('.form-block').hide()
    # if @new_record
    #   @$('.form-block').remove()
    # else
    #   @$('.view-block').show()
    #   @$('.form-block').hide()

  update: (e) ->
    $form = @$(e.target).closest('form')
    # We send form data via ajax so we can capture the response from server
    $.post($form.attr('action'), $form.serialize())
      .done (response) =>
        @$('.view-block').html(response)
        @$('.view-block').show()
        @$('.form-block').hide()
      .fail (response) =>
        @$('.form-block').html(response)

    # Prevent form from being submitted again
    return false

  create: (e) ->
    $form = @$(e.target).closest('form')
    # We send form data via ajax so we can capture the response from server
    $.post($form.attr('action'), $form.serialize())
      .done (response) =>
        @$el.html(response)
      .fail (response) =>
        @$el.html(response)

    # Prevent form from being submitted again
    return false
