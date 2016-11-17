class MS.Views.TimelineBatchActionsView extends Backbone.View

  el: '#adjust-dates-modal'

  events: (params) ->
    'confirm:complete .batch-actions .batch-action': 'adjustForm'
    'click .adjust-dates-confirm': 'hideAdjustDatesModal'

  show: (options) ->
    stepIds = options.stepIds
    @form = options.form
    disabled = stepIds.length < 1
    $('.adjust-dates-confirm').toggleClass('disabled', disabled)
    $('.adjust-dates-confirm').prop('disabled', disabled)
    @$el.modal('show')

  adjustForm: (e) ->
    item = e.currentTarget
    methodKey = @$(item).attr('data-method-key')
    actionKey = @$(item).attr('data-action-key')

    @form.find('input[name=_method]').attr('value', methodKey)
    @form.attr('action', actionKey)

    @form.submit()

  hideAdjustDatesModal: (e) ->
    @$el.modal('hide')
    @adjustForm(e)
