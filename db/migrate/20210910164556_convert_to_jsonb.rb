class ConvertToJsonb < ActiveRecord::Migration[6.1]
  def up
    convert_to_jsonb(:accounting_accounts, :quickbooks_data)
    convert_to_jsonb(:accounting_customers, :quickbooks_data)
    convert_to_jsonb(:accounting_qb_departments, :quickbooks_data)
    convert_to_jsonb(:accounting_qb_vendors, :quickbooks_data)
    convert_to_jsonb(:accounting_sync_issues, :custom_data)
    convert_to_jsonb(:accounting_transactions, :quickbooks_data)
    convert_to_jsonb(:data_exports, :data)
    convert_to_jsonb(:divisions, :custom_data)
    convert_to_jsonb(:divisions, :locales)
    convert_to_jsonb(:organizations, :custom_data)
    convert_to_jsonb(:projects, :custom_data)
    convert_to_jsonb(:response_sets, :custom_data)
    convert_to_jsonb(:tasks, :activity_message_data)
    convert_to_jsonb(:tasks, :custom_error_data)
  end

  def down
    convert_to_json(:accounting_accounts, :quickbooks_data)
    convert_to_json(:accounting_customers, :quickbooks_data)
    convert_to_json(:accounting_qb_departments, :quickbooks_data)
    convert_to_json(:accounting_qb_vendors, :quickbooks_data)
    convert_to_json(:accounting_sync_issues, :custom_data)
    convert_to_json(:accounting_transactions, :quickbooks_data)
    convert_to_json(:data_exports, :data)
    convert_to_json(:divisions, :custom_data)
    convert_to_json(:divisions, :locales)
    convert_to_json(:organizations, :custom_data)
    convert_to_json(:projects, :custom_data)
    convert_to_json(:response_sets, :custom_data)
    convert_to_json(:tasks, :activity_message_data)
    convert_to_json(:tasks, :custom_error_data)
  end

  private

  def convert_to_jsonb(table, col)
    execute("ALTER TABLE #{table} ALTER COLUMN #{col} SET DATA TYPE jsonb USING #{col}::jsonb")
  end

  def convert_to_json(table, col)
    execute("ALTER TABLE #{table} ALTER COLUMN #{col} SET DATA TYPE json USING #{col}::json")
  end
end
