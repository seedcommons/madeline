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

      # ajaxError sometimes catches 0 and 200 erroneously
      # 422 should be handled by specific View
      return if [0, 200, 422].indexOf(parseInt(status)) != -1

      e.stopPropagation()
      $('.modal').modal('hide')
      MS.loadingIndicator.hide()
      switch status
        when 403
          @showErrorModal I18n.t('unauthorized_error')
        else
          @showErrorModal()
