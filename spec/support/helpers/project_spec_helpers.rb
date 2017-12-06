module ProjectSpecHelpers
  shared_context 'project' do
    let(:person_1) { create(:person) }
    let(:person_2) { create(:person) }
    let(:p_1) { build(:basic_project, primary_agent_id: person_1.id, secondary_agent_id: person_1.id) }
    let(:p_2) { build(:basic_project, primary_agent_id: person_1.id, secondary_agent_id: person_2.id) }
  end
end
