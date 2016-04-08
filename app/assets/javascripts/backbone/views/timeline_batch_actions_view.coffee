class MS.Views.TimelineBatchActionsView extends Backbone.View

  el: 'body'

  events: (params) ->
    'confirm:complete .batch-actions .batch-action': 'adjustForm'
    'click #adjust-dates-confirm': 'hideAdjustDatesModal'
    'shown.bs.modal #adjust-dates': 'showAdjustDatesModal'
  
  adjustForm: (e) ->
    item = e.currentTarget
    methodKey = $(item).attr('data-method-key')
    actionKey = $(item).attr('data-action-key')

    $form = $(item).closest('form')

    $form.find('#set-method').attr('value', methodKey)
    $form.attr('action', actionKey)

    $form.submit()

  hideAdjustDatesModal: (e) ->
    $('#adjust-dates-modal').modal('hide')
    @.adjustForm(e)

  showAdjustDatesModal: (e) ->
    $('#adjust-dates-modal').focus()
