# == Schema Information
#
# Table name: countries
#
#  created_at          :datetime         not null
#  default_currency_id :integer          not null
#  id                  :integer          not null, primary key
#  iso_code            :string(2)        not null
#  name                :string           not null
#  updated_at          :datetime         not null
#
# Foreign Keys
#
#  fk_rails_...  (default_currency_id => currencies.id)
#

require 'rails_helper'

describe Country, :type => :model do
  it 'has a valid factory' do
    expect(create(:country)).to be_valid
  end
end
