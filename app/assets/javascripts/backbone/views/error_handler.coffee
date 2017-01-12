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
    $(document).ajaxError (e, jqXHR) =>
      e.stopPropagation()
      $('.modal').modal('hide')
      MS.loadingIndicator.hide()
      switch jqXHR.status
        when 403
          @showErrorModal I18n.t('unauthorized_error')
        else
          @showErrorModal()
