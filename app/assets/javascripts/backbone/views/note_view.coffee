class MS.Views.NoteView extends Backbone.View

  initialize: (params) ->
    @new_record = params.new_record
    new MS.Views.AutoLoadingIndicatorView()

  events:
    'click a.edit-action': 'showForm'
    'click .cancel': 'cancel'
    'submit .edit-form': 'update'
    'submit .new-form': 'create'

  showForm: (e) ->
    e.preventDefault()
    @$('.view-block').hide()
    @$('.form-block').show()

  cancel: (e) ->
    e.preventDefault()
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
