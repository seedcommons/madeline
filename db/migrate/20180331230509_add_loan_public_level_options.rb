class AddLoanPublicLevelOptions < ActiveRecord::Migration[5.1]
  def up
    loan_public_level = OptionSet.find_or_create_by(division: Division.root, model_type: Loan.name,
      model_attribute: 'public_level')
    loan_public_level.options.destroy_all
    loan_public_level.options.create(value: 'featured', position: 1,
      label_translations: {en: 'Featured', es: 'Destacado'})
    loan_public_level.options.create(value: 'hidden', position: 2,
      label_translations: {en: 'Hidden', es: 'Oculto'})
  end

  def down
    loan_public_level = OptionSet.find_or_create_by(division: Division.root, model_type: Loan.name,
      model_attribute: 'public_level')
    loan_public_level.options.destroy_all
    loan_public_level.destroy
  end
end
