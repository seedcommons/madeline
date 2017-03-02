# == Schema Information
#
# Table name: countries
#
#  created_at          :datetime         not null
#  default_currency_id :integer
#  id                  :integer          not null, primary key
#  iso_code            :string(2)
#  name                :string
#  updated_at          :datetime         not null
#
# Foreign Keys
#
#  fk_rails_cc2d004fbb  (default_currency_id => currencies.id)
#

require 'rails_helper'

describe Country, :type => :model do
  it 'has a valid factory' do
    expect(create(:country)).to be_valid
  end
end
