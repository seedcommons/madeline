require 'rails_helper'

describe ProjectLog, :type => :model do
  before { pending 're-implement in new project' }
  it_should_behave_like 'translatable', ['Explanation', 'DetailedExplanation']
  it_should_behave_like 'mediable'

  it 'has a valid factory' do
    expect(create(:project_log)).to be_valid
  end
end
