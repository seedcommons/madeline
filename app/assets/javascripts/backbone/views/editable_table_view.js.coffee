class MS.Views.EditableTableView extends Backbone.View

  el: "table.editable-table"

  editableTableInit: (e) ->
    $('.editable-table tbody').sortable({
      handle: "[data-action='move']"
    })

  addRow: (e) ->
    e.preventDefault
    $button = $(e.currentTarget)
    $table = $button.closest('.table-container').find("table")
    $new_row = $table.find('tr.hidden').clone()
    $new_row.removeClass('hidden')
    $table.append($new_row)

  removeRow: (e) ->
    e.preventDefault()
    $row = $(e.currentTarget).closest('tr')
    $row.remove()
