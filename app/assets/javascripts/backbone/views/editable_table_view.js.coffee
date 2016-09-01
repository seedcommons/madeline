class MS.Views.EditableTableView extends Backbone.View

  el: "table.editable-table"

  initialize: (params) ->

  editableTableInit: (e) ->
    $('.editable-table tbody').sortable({
      handle: ".hand"
      # containment: "parent",
      # delay: 150,
      # distance: 5,
    });

  removeRow: (e) ->
    e.preventDefault()
    $row = $(e.currentTarget).closest('tr')
    $row.remove()
