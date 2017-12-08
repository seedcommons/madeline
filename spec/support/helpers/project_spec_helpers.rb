module ProjectSpecHelpers
  shared_context 'project' do
    let(:person_1) { create(:person) }
    let(:person_2) { create(:person) }
    let(:p_1) { build(:basic_project, primary_agent_id: person_1.id, secondary_agent_id: person_1.id) }
    let(:p_2) { build(:basic_project, primary_agent_id: person_1.id, secondary_agent_id: person_2.id) }
    let(:project) { create(:basic_project, primary_agent: person_1, secondary_agent: person_2) }
    let(:error) { 'The point person for this project cannot be the same as the second point person' }

    context 'update' do
      it 'raises error if agents are the same' do
        project.secondary_agent = person_1
        project.save

        expect(project).not_to be_valid
        expect(project.errors[:primary_agent].join).to match(error)
      end
    end
  end
end
