class CreateLoans < ActiveRecord::Migration
  def change
    create_table :loans do |t|
      t.references :division, index: true, foreign_key: true
      t.references :organization, index:true, foreign_key: true
      t.string :name
      t.references :primary_agent, references: :people
      t.references :secondary_agent, references: :people
      t.string :status
      t.decimal :amount
      t.references :currency, index: true, foreign_key: true
      t.decimal :rate
      t.integer :length_months
      t.references :representative, references: :people
      t.date :signing_date
      t.date :first_interest_payment_date
      t.date :first_payment_date
      t.date :target_end_date
      t.decimal :projected_return
      t.string :publicity_status

      t.timestamps null: false
    end
    add_foreign_key :loans, :people, column: :primary_agent_id
    add_foreign_key :loans, :people, column: :secondary_agent_id
    add_foreign_key :loans, :people, column: :representative_id
  end
end
