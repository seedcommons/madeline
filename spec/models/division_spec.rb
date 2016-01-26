require 'rails_helper'

describe Division, :type => :model do
  it 'has a valid factory' do
    expect(create(:division)).to be_valid
  end
end
