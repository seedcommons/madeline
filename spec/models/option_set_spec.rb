require 'rails_helper'

describe OptionSet, type: :model do

  before do
    seed_data
    #UNUSED AdHocCacheManager.clear_all
  end

  it 'has a valid factory' do
    expect(create(:option_set)).to be_valid
  end

  it 'can fetch instance from including class' do
    expect(OptionSet.fetch(Loan, :status)).to be
  end

  #todo: confirm if we want to verify existence of any system required seed data or not
  xcontext 'seed data' do
    it 'has expected Loan data' do
      expect(Loan.status_option_set).to be
      expect(Loan.status_option_values.size).to eq(8)
      expect(Loan.loan_type_option_set).to be
      expect(Loan.loan_type_option_values.size).to eq(7)
    end
  end


  xcontext 'Loan.status_option_set' do

    it 'has expected behavior and data' do
      option_set = Loan.status_option_set
      expect(option_set.translated_list.first[:label]).to eq('Active')
      expect(option_set.translated_list(:es).last[:label]).to eq('Relacion Activo')
      expect(option_set.translated_label(3)).to eq('Frozen')
      expect(option_set.translated_label(2, :es)).to eq('Prestamo Completo')
      expect(option_set.value_for_label('Refinanced')).to eq(6)
    end

  end

end

