class CreateLoanTransactionTypes < ActiveRecord::Migration
  def change
    create_table :loan_transaction_types do |t|
      t.string :name
      t.int :position

      t.timestamps null: false
    end
  end
end
