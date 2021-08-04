class AllowNullLastUpdatedAtOnConnection < ActiveRecord::Migration[5.2]
  def change
    change_column_null :accounting_qb_connections, :last_updated_at, true
  end
end
