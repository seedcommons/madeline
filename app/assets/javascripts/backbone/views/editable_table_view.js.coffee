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
    $section = $(e.currentTarget)
    $tables = $section.find('.editable-table')
    console.log($tables)
    self = @

    # for index,object in $tables
    $section.find('.editable-table').each (index) ->
      console.log(this)
      $table = $(this)
      tableKey = $table.data('table')
      $rows = $table.find('tbody').find('tr')
      tableData = []

      for key,row of $rows
        if !isNaN(key)
          $row = $(row)

          rowResponse = switch tableKey
            when 'fixed-costs' then self.formatFixedCostsInput($row)
            when 'products' then self.formatProductsInput($row)

          if rowResponse.rowData
            tableData.push(rowResponse.rowData)

      # Save generated table data to the master input used in form sent to server
      $masterInput = $table.closest('.editable-tables').find('[data-container]')
      tableData = {"#{tableKey}": tableData}
      $masterInput.attr("data-#{tableKey}", JSON.stringify(tableData))
      console.log(tableData)
      console.log($masterInput)

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

  formatProductsInput: ($row) ->
    name = $row.find('[data-input="name"]').val()
    description = $row.find('[data-input="description"]').val()
    unit = $row.find('[data-input="unit"]').val()
    price = $row.find('[data-input="price"]').val()
    cost = $row.find('[data-input="cost"]').val()
    quantity = $row.find('[data-input="quantity"]').val()

    # Only format rows that have a product name, price, and cost
    if Boolean(name) && Boolean(price) && Boolean(cost)
      rowData = {
        name: name,
        description: description,
        unit: unit,
        price: price,
        cost: cost,
        quantity: quantity
      }
      return {rowData: rowData}
    else
      return false
