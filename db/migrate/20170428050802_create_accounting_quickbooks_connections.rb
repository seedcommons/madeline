class CreateAccountingQuickbooksConnections < ActiveRecord::Migration
  def change
    create_table :accounting_quickbooks_connections do |t|
      t.references :division, index: true, foreign_key: true
      t.string :token
      t.string :secret
      t.string :realm_id
      t.datetime :token_expires_at
      t.datetime :last_updated_at

      t.timestamps null: false
    end

    # We only need to migrate the root division at the moment
    # division = Division.root
    # Accounting::Quickbooks::Connection.create(division.quickbooks_data.merge(division: division))

    remove_column :divisions, :quickbooks_data
  end
end
