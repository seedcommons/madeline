require 'rails_helper'

describe Language, :type => :model do
  it 'has a valid factory' do
    expect(create(:language)).to be_valid
  end
end
