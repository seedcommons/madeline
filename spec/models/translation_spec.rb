require 'rails_helper'

describe Translation, :type => :model do
  it 'has a valid factory' do
    expect(create(:translation)).to be_valid
  end
end
