class MS.Views.TimelineBatchActionsView extends Backbone.View

  events: (params) ->
    'confirm:complete .batch-actions .batch-action': 'adjustForm'
    'click .adjust-dates-confirm': 'hideAdjustDatesModal'
    'show.bs.modal': 'resetModal'

  resetModal: (e) ->
    stepIds = @$('.step-ids').val()
    disabled = stepIds.length < 1
    @checkForDependentSteps(stepIds)
    @$('.adjust-dates-confirm').toggleClass('disabled', disabled)
    @$('.adjust-dates-confirm').prop('disabled', disabled)

  adjustForm: (e) ->
    item = e.currentTarget
    methodKey = @$(item).attr('data-method-key')
    actionKey = @$(item).attr('data-action-key')

    $form = @$(item).closest('form')

    $form.find('input[name=_method]').attr('value', methodKey)
    $form.attr('action', actionKey)

    $form.submit()

  checkForDependentSteps: (stepIds) ->
    $('.dependent-steps-notice').hide()
    boxes = $(".select-step[data-id][data-precedent-id]:checked")
    if boxes.length > 0
      $('.dependent-steps-notice').show()

  hideAdjustDatesModal: (e) ->
    @$('.adjust-dates-modal').modal('hide')
    @adjustForm(e)
