require 'rails_helper'

describe Country, :type => :model do
  it 'has a valid factory' do
    expect(create(:country)).to be_valid
  end
end
