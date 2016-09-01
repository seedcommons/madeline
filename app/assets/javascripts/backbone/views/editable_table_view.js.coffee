class MS.Views.EditableTableView extends Backbone.View

  el: "table.editable-table"

  initialize: (params) ->
    # @$el.find('tbody').sortable();
    $('tbody').sortable();

  editableTableInit: ->
    $('tbody').sortable();

  # events:
