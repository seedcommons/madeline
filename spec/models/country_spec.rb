require 'rails_helper'

describe Country, :type => :model do
  # before { pending 're-implement in new project' }
  it 'has a valid factory' do
    expect(create(:country)).to be_valid
  end
end
