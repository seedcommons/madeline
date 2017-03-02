# == Schema Information
#
# Table name: option_sets
#
#  created_at      :datetime         not null
#  division_id     :integer          not null
#  id              :integer          not null, primary key
#  model_attribute :string
#  model_type      :string
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_option_sets_on_division_id  (division_id)
#
# Foreign Keys
#
#  fk_rails_1565c19047  (division_id => divisions.id)
#

require 'rails_helper'

describe OptionSet, type: :model do

  before do
    root_division
  end

  it 'has a valid factory' do
    expect(create(:option_set)).to be_valid
  end

  it 'can fetch instance from including class' do
    expect(OptionSet.fetch(Loan, :status)).to be
  end

  it 'has expected behaviors' do
    option_set = Loan.status_option_set

    expect(option_set).to be_valid
    option_set.options.create(value: 'active', label_translations: {I18n.locale => 'Active'}, migration_id: 1)
    expect(option_set.value_for_migration_id(1)).to eq('active')
    expect(option_set.translated_list.first.first.to_s).to eq('Active')
    expect(option_set.translated_label_by_value('active').to_s).to eq('Active')
  end


end
