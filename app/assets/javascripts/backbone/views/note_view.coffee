class MS.Views.NoteView extends Backbone.View

  initialize: (params) ->
    @new_record = params.new_record
    new MS.Views.AutoLoadingIndicatorView()

  events:
    'click a.edit-action': 'showForm'
    'click .cancel': 'cancel'
    'submit form.inline-form': 'onSubmit'
    'ajax:success': 'ajaxSuccess'

  showForm: (e) ->
    e.preventDefault()
    @$('.view-block').hide()
    @$('.form-block').show()

  cancel: (e) ->
    e.preventDefault()
    if @new_record
      @$('.form-block').remove()
    else
      @$('.view-block').show()
      @$('.form-block').hide()
