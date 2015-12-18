require 'rails_helper'

describe BasicProject, :type => :model do
  before { pending 're-implement in new project' }
  it 'has a valid factory' do
    expect(create(:basic_project)).to be_valid
  end
end
