require 'rails_helper'

describe Media, :type => :model do
  before { pending 're-implement in new project' }

  it 'has a valid factory' do
    expect(create(:media)).to be_valid
  end
end
