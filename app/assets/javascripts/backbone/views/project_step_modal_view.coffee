class MS.Views.ProjectStepModalView extends Backbone.View

  el: '#project-step-modal'

  initialize: (params) ->
    new MS.Views.AutoLoadingIndicatorView()
    @done = (->) # Empty function

  events:
    'click .cancel': 'close'
    'click .submit': 'submitForm'
    'ajax:complete form': 'submitComplete'
    'confirm:complete a.delete-action': 'delete'

  show: (id, done) ->
    @done = done
    # The show method is only used by the calendar. Hopefully contexts can go away later.
    @loadContent("/admin/project_steps/#{id}?context=calendar")

  new: (loanId, done, options = {}) ->
    @done = done
    date = options.date || ''
    parentId = options.parentId if options.parentId
    @loadContent("/admin/project_steps/new?loan_id=#{loanId}&context=timeline_table&date=#{date}&parent_id=#{parentId}")

  edit: (id, done) ->
    @done = done
    @loadContent("/admin/project_steps/#{id}/edit?context=timeline_table")

  delete: (e) ->
    id = @$(e.currentTarget).closest('[data-id]').data('id')
    $.post "/admin/project_steps/#{id}", {'_method': 'DELETE'}, =>
      @close()
      @runAndResetDoneCallback()

  close: ->
    @$el.modal('hide')

  submitForm: ->
    @$('form').submit()

  submitComplete: (e, data) ->
    if parseInt(data.status) == 200 # data.status is sometimes a string, sometimes an int!?
      @close()
      json = data.responseJSON || {}
      if json.days_shifted
        @showMoveStepModal(json.id, json.days_shifted)
      else
        @runAndResetDoneCallback()
    else
      @replaceContent(data.responseText)

  loadContent: (url) ->
    $.get url, (html) =>
      @replaceContent(html)
      @$el.modal('show')

  replaceContent: (html) ->
    @$el.find('.modal-content').html(html)
    new MS.Views.TranslationsView(el: @$('[data-content-translatable="project_step"]'))

  showMoveStepModal: (id, daysShifted) ->
    unless @moveStepModal
      el = $('<div>').insertAfter(@$el)
      @moveStepModal = new MS.Views.MoveStepModalView(el: el, context: 'edit_date')
    @moveStepModal.show(id, daysShifted).done => @runAndResetDoneCallback()

  runAndResetDoneCallback: ->
    @done() if @done
    @done = (->) # Reset to empty function.
