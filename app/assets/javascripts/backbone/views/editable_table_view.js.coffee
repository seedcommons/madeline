class MS.Views.EditableTableView extends Backbone.View

  # The view is called from the loan questionnaires view.

  events:
    'click tr [data-action="delete"]': 'removeRow'
    'click .actions [data-action="add"]': 'addRow'

  initialize: (e) ->
    @$el.find('tbody').sortable(
      handle: "[data-action='move']"
    )

  addRow: (e) ->
    e.preventDefault()
    $button = @$(e.currentTarget)
    $table = $button.closest('table')
    $newRow = $table.find('tr.hidden').clone()
    $newRow.removeClass('hidden')
    $row = @appendRowBeforeTotals($table, $newRow)
    @rowAdded($table, $row)

  appendRowBeforeTotals: ($table, $row) ->
    $totalsRow = $table.find("tr[data-group='totals']")

    if $totalsRow.length > 0
      $totalsRow.before($row)
    else
      $table.append($row)

    $row

  removeRow: (e) ->
    e.preventDefault()
    @$(e.currentTarget).closest('tr').remove()

  rowAdded: ($table, $row) ->
    @trigger('EditableTableView:rowAdded', $table, $row, @)

