require 'rails_helper'

describe Organization, type: :model do
  it 'has a valid factory' do
    expect(create(:organization)).to be_valid
  end
end
