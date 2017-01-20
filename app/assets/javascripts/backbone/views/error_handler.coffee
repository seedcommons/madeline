class MS.Views.ErrorHandler extends Backbone.View

  el: 'body'

  initialize: ->
    MS.loadingIndicator = @$('#glb-load-ind')
    MS.errorModal = @$('#glb-error-modal')
    @errorModalDefaultText = I18n.t('error_notification')
    @handleAjaxErrors()

  showErrorModal: (error = @errorModalDefaultText) ->
    MS.errorModal.find('.modal-body').text(error)
    MS.errorModal.modal('show')

  handleAjaxErrors: ->
    $(document).ajaxError (e, jqXHR, ajaxSettings, errorString) =>
      status = parseInt(jqXHR.status) # status can sometimes be a string

      # ajaxError sometimes called for status codes 0 and 200 erroneously
      # In one case (0), the errorString is 'canceled'. This is thrown seemingly before the request
      # is complete. It seems to have something to do with file uploads.
      # In another case (200), this seems to be because jquery is trying to `eval` the response,
      # but the response is HTML. We need to figure out how to get it to not do that.
      # In the case of a 422, this should be handled by specific view and so we never want to handled
      # it at this level.
      return if [0, 200, 422].indexOf(status) != -1

      $('.modal').modal('hide')
      MS.loadingIndicator.hide()
      switch status
        when 403
          @showErrorModal I18n.t('unauthorized_error')
        else
          @showErrorModal()
