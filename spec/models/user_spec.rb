require 'rails_helper'

describe User, :type => :model do
  it 'has a valid factory' do
    expect(create(:user)).to be_valid
  end
end
