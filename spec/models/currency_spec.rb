# == Schema Information
#
# Table name: currencies
#
#  code         :string
#  created_at   :datetime         not null
#  id           :integer          not null, primary key
#  name         :string
#  short_symbol :string
#  symbol       :string
#  updated_at   :datetime         not null
#

require 'rails_helper'

describe Currency, :type => :model do
  it 'has a valid factory' do
    expect(create(:currency)).to be_valid
  end
end
