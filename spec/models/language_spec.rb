require 'rails_helper'

describe Language, :type => :model do
  before { pending 're-implement in new project' }
  it 'has a valid factory' do
    expect(create(:language)).to be_valid
  end
end
