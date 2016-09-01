class MS.Views.EditableTableView extends Backbone.View

  el: "table.editable-table"

  editableTableInit: (e) ->
    $('.editable-table tbody').sortable({
      handle: "[data-action='move']"
    })

  addRow: (e) ->
    e.preventDefault()
    $button = $(e.currentTarget)
    $table = $button.closest('.table-container').find("table")
    $new_row = $table.find('tr.hidden').clone()
    $new_row.removeClass('hidden')
    $table.append($new_row)

  removeRow: (e) ->
    e.preventDefault()
    $row = $(e.currentTarget).closest('tr')
    $row.remove()

  saveTable: (e) ->
    e.preventDefault()
    $table = $(e.currentTarget).closest('.table-container').find('table')
    tableKey = $table.data('table')
    $rows = $table.find('tbody').find('tr')

    tableData = []
    for key,row of $rows
      if !isNaN(key)
        $row = $(row)

        rowResponse = switch tableKey
          when 'fixed_costs' then @formatFixedCostsInput($row)
          # when 'products' then
          # else

        if rowResponse.rowData
          # console.log(rowResponse.rowData)
          tableData.push(rowResponse.rowData)

    console.log(tableData)

  formatFixedCostsInput: ($row) ->
    name = $row.find('[data-input="name"]').val()
    amount = $row.find('[data-input="amount"]').val()

    # Only format rows that have a name and amount
    if Boolean(name) && Boolean(amount)
      rowData = {
        name: name,
        amount: amount
      }
      return {rowData: rowData}
    else
      return false
