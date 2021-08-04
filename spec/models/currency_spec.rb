require 'rails_helper'

describe Currency, :type => :model do
  it 'has a valid factory' do
    expect(create(:currency)).to be_valid
  end
end
