class MS.Views.LoanView extends Backbone.View

  el: '.loan'

  events: (params) ->
    'change #loan_primary_agent_id': 'removeFromSecAgentList'
    'change #loan_secondary_agent_id': 'removeFromPryAgentList'

  removeFromSecAgentList: ->
    e = document.getElementById('loan_primary_agent_id')

    selected = e.options[e.selectedIndex].value

    $('#loan_secondary_agent_id').find('option[value=' + selected + ']').remove()

  removeFromPryAgentList: ->
    e = document.getElementById('loan_secondary_agent_id')

    selected = e.options[e.selectedIndex].value

    $('#loan_primary_agent_id').find('option[value=' + selected + ']').remove()
