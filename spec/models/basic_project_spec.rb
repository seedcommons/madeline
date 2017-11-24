require 'rails_helper'

describe BasicProject, type: :model do
  context 'primary and secondary agents' do
    let(:person_1) { create(:person) }
    let(:person_2) { create(:person) }
    let(:bp_1) { build(:basic_project, primary_agent_id: person_1.id, secondary_agent_id: person_1.id) }
    let(:bp_2) { build(:basic_project, primary_agent_id: person_1.id, secondary_agent_id: person_2.id) }

    it 'raises error if agents are the same' do
      error = 'The primary agent for this project cannot be the same as the secondary agent'
      expect(bp_1).not_to be_valid
      expect(bp_1.errors[:primary_agent].join).to match(error)
    end

    it 'does not raise error for different agents' do
      expect(bp_2).to be_valid
    end
  end
end
