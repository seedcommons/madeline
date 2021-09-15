# This view is for general functions for the entire app, including admin and frontend
# Should be used sparingly. Prefer separate views (perhaps instantiated from in here)
# for cohesive pieces of functionality.
class MS.Views.ApplicationView extends Backbone.View
  el: 'body'

  initialize: (params) ->
    new MS.Views.ErrorHandler({locale: params.locale})
    new MS.Views.Expander()
    MS.alert = (html) ->
      $alert = $(html).hide()
      $alert.appendTo($('.alerts')).show('fast')
    MS.dateFormats = params.dateFormats
    $.fn.datepicker.defaults.language = params.locale
    @initializeAutocompleteSelects()

  events: ->
    'click .more': 'toggleExpanded'
    'click .less': 'toggleExpanded'
    'shown.bs.modal .modal': 'preventMultipleModalBackdrops'

  initializeAutocompleteSelects: ->
    $('.autocomplete-select').select2()

  preventMultipleModalBackdrops: ->
    if (@$(".modal-backdrop").length > 1)
      @$(".modal-backdrop").not(':first').remove()

  toggleExpanded: (e) ->
    @$(e.currentTarget).closest(".expandable").toggleClass("expanded")
