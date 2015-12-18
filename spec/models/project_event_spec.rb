require 'rails_helper'

describe ProjectEvent, :type => :model do
  before { pending 're-implement in new project' }
  it_should_behave_like 'translatable', ['Summary', 'Details']

  it 'has a valid factory' do
    expect(create(:project_event)).to be_valid
  end
end
