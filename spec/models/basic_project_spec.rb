require 'rails_helper'

describe BasicProject, type: :model do
  include_context 'project'

  it_should_behave_like 'translatable', ['summary', 'details']
  it_should_behave_like 'option_settable', ['status']

  it 'has a valid factory' do
    expect(create(:basic_project)).to be_valid
  end

  context 'primary and secondary agents' do
    it 'raises error if agents are the same' do
      error = 'The point person for this project cannot be the same as the second point person'
      expect(p_1).not_to be_valid
      expect(p_1.errors[:primary_agent].join).to match(error)
    end

    it 'does not raise error for different agents' do
      expect(p_2).to be_valid
    end
  end
end
