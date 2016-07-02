class MS.Views.LoanQuestionnairesView extends Backbone.View

  el: 'section.questionnaires'

  initialize: (options) ->
    @loanId = options.loanId
    @refreshContent()

  events:
    'ajax:error': 'submitError'
    'click .filter-switch .btn': 'changeQuestionnaire'

  refreshContent: ->
    MS.loadingIndicator.show()
    @$('.questionnaires-content').empty()
    $.get "/admin/loans/#{@loanId}/questionnaires", (html) =>
      MS.loadingIndicator.hide()
      @$('.questionnaires-content').html(html)
      @initTopButtons()

  submitError: (e) ->
    e.stopPropagation()
    MS.errorModal.modal('show')
    MS.loadingIndicator.hide()

  initTopButtons: ->
    selected = URI(window.location.href).query(true)['selected'] || 'criteria'
    @showQuestionnaire(selected)
    @$('.filter-switch .btn').removeClass('active')
    @$(".filter-switch .btn[data-attrib=#{selected}]").addClass('active')

  changeQuestionnaire: (e) ->
    selected = $(e.currentTarget).closest('.btn').data('attrib')
    @showQuestionnaire(selected)
    url = URI(window.location.href).setQuery('selected', selected).href()
    history.pushState(null, "", url)

  showQuestionnaire: (attrib) ->
    @$('.questionnaire').hide()
    @$(".questionnaire[data-attrib=#{attrib}]").show()

