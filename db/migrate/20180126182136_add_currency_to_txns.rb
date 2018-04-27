class AddCurrencyToTxns < ActiveRecord::Migration[5.1]

  def change
    valid_txns = Accounting::Transaction.all.where(currency: nil).where.not(project: nil)

    valid_txns.each do |txn|
      txn.update_attribute(:currency_id, lookup_currency(txn).id)
    end
  end

  private

  def lookup_currency(txn)
    project = txn.project

    if txn.quickbooks_data && txn.quickbooks_data[:currency_ref]
      Currency.find_by(code: quickbooks_data[:currency_ref][:value]).try(:id)
    elsif project
      Currency.find_by(id: project.currency_id)
    end
  end
end
