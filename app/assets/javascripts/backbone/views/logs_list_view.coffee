class MS.Views.LogsListView extends Backbone.View

  el: '.logs-list'

  initialize: (options) ->
    @refreshUrl = options.refreshUrl
    # @el = options.el
    # console.log(@refreshUrl)
    # @loanId = options.loanId if options.loanId
    # @stepId = options.stepId if options.stepId
    # @submitted = false

  events:
    'click .log [data-action="edit"]': 'editLog'
    # 'click [data-action="submit"]': 'submitForm'
    'ajax:complete': 'refresh'

  editLog: (e) ->
    e.preventDefault()
    logId = @$(e.currentTarget).closest('.log').data('id')

    # new MS.Views.LogModalView

    # # MS.loadingIndicator.show()
    # $.get "/admin/logs/#{logId}/edit", (html) =>
    #   @replaceContent(html)

  # replaceContent: (html) ->
  #   @$('#project-log-modal').html(html)
  #   $modal = @$('#project-log-modal .modal')
  #   new MS.Views.TranslationsView(el: @$('[data-content-translatable="project_log"]'))
  #   $modal.find('.empty-log-error').hide()
  #   $modal.modal('show').modal('show')
  #   # MS.loadingIndicator.hide()
  #
  # submitForm: (e) ->
  #   e.preventDefault()
  #   $form = @$('#project-log-modal form')
  #   submitted = @submitted
  #
  #   # Check to make sure summary is completed for at least one language
  #   $form.find("[data-translatable='common.summary']").each ->
  #     if ($.trim($(this).val()) != '')
  #       submitted = true
    #
    # if submitted
    #   $form.submit()
    #   @$('#project-log-modal .modal').modal('hide')
    # else
    #   $form.find('.empty-log-error').show()

  refresh: () ->
    MS.loadingIndicator.show()
    $.get @refreshUrl, (html) =>
      MS.loadingIndicator.hide()
      console.log(html)
      @$el.replaceWith(html)
