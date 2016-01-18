require 'rails_helper'

describe ProjectStep, :type => :model do
  it_should_behave_like 'translatable', ['summary', 'details']
  it_should_behave_like 'option_settable', ['step_type']

  it 'has a valid factory' do
    expect(create(:project_step)).to be_valid
  end
end
