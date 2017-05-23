class MS.Views.TimelineBatchActionsView extends Backbone.View

  events: (params) ->
    'confirm:complete .batch-actions .batch-action': 'adjustForm'
    'click .adjust-dates-confirm': 'hideAdjustDatesModal'
    'show.bs.modal': 'resetModal'

  resetModal: (e) ->
    stepIds = @$('.step-ids').val()
    disabled = stepIds.length < 1
    @checkForUnselectedPrecedents(stepIds)
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

  # Check the selected steps for any steps with precedents
  # If the step has a precedent step, show a message
  checkForUnselectedPrecedents: (stepIds) ->
    @$('#dependent-steps-notice').hide()

    dependents = @$(".select-step[data-id][data-precedent-id]:checked")
    stepIds = @$('.step-ids').val()
    unselectedPrecedentIds = []

    dependents.each ->
      stepId = $(this).data('id')
      precedentId = $(this).data('precedent-id')
      unselectedPrecedentIds.push(precedentId) unless stepIds.includes(precedentId)

    if unselectedPrecedentIds.length > 0
      @$('#dependent-steps-notice').show()

  hideAdjustDatesModal: (e) ->
    @$('.adjust-dates-modal').modal('hide')
    @adjustForm(e)
