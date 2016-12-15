class MS.Views.EditableTableView extends Backbone.View

  # This view may control multiple elements at once.
  # The view is called from the loan questionnaires view.
  el: ".editable-table"

  events:
    'click tr [data-action="delete"]': 'removeRow'
    'click .actions [data-action="add"]': 'addRow'

  initialize: (e) ->
    @refresh()

  refresh: (e) ->
    @$el.find('tbody').sortable({
      handle: "[data-action='move']"
    })

  addRow: (e) ->
    e.preventDefault()
    $button = @$(e.currentTarget)
    $table = $button.closest('table')
    $new_row = $table.find('tr.hidden').clone()
    $new_row.removeClass('hidden')
    $table.append($new_row)

  removeRow: (e) ->
    e.preventDefault()
    $row = @$(e.currentTarget).closest('tr')
    $row.remove()
