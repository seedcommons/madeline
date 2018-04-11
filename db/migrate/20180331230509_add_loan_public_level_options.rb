class AddLoanPublicLevelOptions < ActiveRecord::Migration[5.1]
  def up
    loan_public_level = OptionSet.find_or_create_by(division: Division.root, model_type: Loan.name,
      model_attribute: 'public_level')
    loan_public_level.options.each do |option|
      update_values(option)
      option.save
    end
  end

  def down
  end

  private

  def update_values(o)
    case o.value
      when 'featured'
        o.label_translations.en = 'Featured'
        o.label_translations.es ='Destacado'
      when 'hidden'
        o.label_translations.en = 'Hidden'
        o.label_translations.es = 'Oculto'
    end
  end
end
