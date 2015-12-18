require 'rails_helper'

describe Currency, :type => :model do
  before { pending 're-implement in new project' }
  it 'has a valid factory' do
    expect(create(:currency)).to be_valid
  end
end
