require 'rails_helper'

describe Note, :type => :model do
  it 'has a valid factory' do
    expect(create(:note)).to be_valid
  end
end
