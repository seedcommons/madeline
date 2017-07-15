class AddLoanTransactionTypeOptions < ActiveRecord::Migration
  def up
    loan_transaction_type = OptionSet.find_or_create_by(division: Division.root, model_type: Loan.name,
      model_attribute: 'loan_transaction_type')
    loan_transaction_type.options.create(value: 'interest', position: 1,
      label_translations: {en: 'Interest', es: 'Interés'})
    loan_transaction_type.options.create(value: 'disbursement', position: 2,
      label_translations: {en: 'Disbursement', es: 'Desembolso'})
    loan_transaction_type.options.create(value: 'repayment', position: 3,
      label_translations: {en: 'Repayment', es: 'Reembolso'})
  end

  def down
    loan_transaction_type = OptionSet.find_or_create_by(division: Division.root, model_type: Loan.name,
      model_attribute: 'loan_transaction_type')
    loan_transaction_type.options.destroy_all
    loan_transaction_type.destroy
  end
end
