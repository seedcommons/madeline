require 'rails_helper'

describe ProjectStep, :type => :model do
  it_should_behave_like 'translatable', ['summary', 'details']
  it_should_behave_like 'option_settable', ['step_type']

  it_behaves_like 'timeline_entry'

  it 'has a valid factory' do
    expect(create(:project_step)).to be_valid
  end

  context 'groups' do
    subject(:step) { create(:project_step) }

    let(:new_step) { create(:project_step) }
    let(:group) { create(:project_group) }

    it 'can not have child steps' do
      expect{step.add_child(new_step)}.to raise_error(ProjectStep::NoChildrenAllowedError)
    end
    it 'can be added to a group' do
      group.add_child(step)

      expect(group.children.count).to eq 1
    end
  end

end
