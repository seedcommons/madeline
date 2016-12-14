class MS.Views.LogsListView extends Backbone.View

  events:
    'click .log [data-action="edit"]': 'editLog'

  editLog: (e) ->
    e.preventDefault()
    logId = @$(e.currentTarget).closest('.log').data('id')

    # MS.loadingIndicator.show()
    $.get "/admin/logs/#{logId}/edit", (html) =>
      @replaceContent(html)

  replaceContent: (html) ->
    @$('#project-log-modal').html(html)
    $modal = @$('#project-log-modal .modal')
    new MS.Views.TranslationsView(el: @$('[data-content-translatable="project_log"]'))
    $modal.find('.empty-log-error').hide()
    $modal.modal('show').modal('show')
    # MS.loadingIndicator.hide()
