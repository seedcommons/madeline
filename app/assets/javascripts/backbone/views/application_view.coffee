# This view is for general functions for the entire app, including admin and frontend
# Should be used sparingly. Prefer separate views (perhaps instantiated from in here)
# for cohesive pieces of functionality.
class MS.Views.ApplicationView extends Backbone.View

  el: 'body'

  initialize: ->
    @errorHandlerInit()
    new MS.Views.Expander()
    MS.alert = (html) ->
      $alert = $(html).hide()
      $alert.appendTo($('.alerts')).show('fast')

  events: ->
    'click .more': 'toggleExpanded'
    'click .less': 'toggleExpanded'
    'click .ms-popover': 'showPopover'

  toggleExpanded: (e) ->
    @$(e.currentTarget).closest(".expandable").toggleClass("expanded")

  showPopover: (e) ->
    @curPopover = $(e.currentTarget)
    @curPopover.popover('show')
    self = this
    hide = (e) ->
      unless self.$(e.target).is('.ms-popover')
        self.$('.ms-popover').popover('hide')
        self.$el.off 'click', hide # Unregister for performance reasons
    @$el.on 'click', hide

  errorHandlerInit: ->
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
