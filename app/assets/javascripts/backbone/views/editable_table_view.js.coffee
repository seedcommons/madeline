class MS.Views.EditableTableView extends Backbone.View

  el: "table.editable-table"

  editableTableInit: (e) ->
    $('.editable-table tbody').sortable({
      handle: "[data-action='move']"
    })

  addRow: (e) ->
    e.preventDefault()
    $button = $(e.currentTarget)
    $table = $button.closest('table')
    $new_row = $table.find('tr.hidden').clone()
    $new_row.removeClass('hidden')
    $table.append($new_row)

  removeRow: (e) ->
    e.preventDefault()
    $row = $(e.currentTarget).closest('tr')
    $row.remove()

  saveTableData: (e) ->
    $section = $(e.currentTarget)
    $tables = $section.find('.editable-table')
    self = @

    # Set the master input for the table data to empty
    $section.find('.editable-tables').find('[data-container]').each (index) ->
      $input = $(this)
      $input.val("{}")

    # Save the new data to each master input
    $section.find('.editable-table').each (index) ->
      $table = $(this)
      tableKey = $table.data('table')
      $rows = $table.find('tbody').find('tr')
      tableData = []

      for key,row of $rows
        if !isNaN(key)
          $row = $(row)

          rowResponse = switch tableKey
            when 'fixed_costs' then self.formatFixedCostsInput($row)
            when 'products' then self.formatProductsInput($row)

          if rowResponse.rowData
            tableData.push(rowResponse.rowData)

      # Save generated table data to the master input, whose value is sent to server
      $masterInput = $table.closest('.editable-tables').find('[data-container]')
      masterInputValue = JSON.parse($masterInput.val())
      masterInputValue["#{tableKey}"] = tableData
      $masterInput.val(JSON.stringify(masterInputValue))

  formatFixedCostsInput: ($row) ->
    name = $row.find('[data-input="name"]').val()
    amount = $row.find('[data-input="amount"]').val()

    # Only format rows that have a name and amount
    if name && amount
      rowData = {
        name: name,
        amount: Number(amount)
      }
      return {rowData: rowData}
    else
      return false

  formatProductsInput: ($row) ->
    name = $row.find('[data-input="name"]').val()
    description = $row.find('[data-input="description"]').val()
    unit = $row.find('[data-input="unit"]').val()
    price = $row.find('[data-input="price"]').val()
    cost = $row.find('[data-input="cost"]').val()
    quantity = $row.find('[data-input="quantity"]').val()

    # Only format rows that have a product name, price, and cost
    if name && price && cost
      rowData = {
        name: name,
        description: description,
        unit: unit,
        price: Number(price),
        cost: Number(cost),
        quantity: Number(quantity)
      }
      return {rowData: rowData}
    else
      return false
