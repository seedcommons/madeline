require 'rails_helper'

describe ProjectGroup, :type => :model do
  it_should_behave_like 'translatable', ['summary', 'details']
  it_should_behave_like 'option_settable', ['step_type']

  it 'has a valid factory' do
    expect(create(:project_group)).to be_valid
  end

  it 'can not be unfinalized after 24 hours' do
    step = create(:project_group, is_finalized: true, finalized_at: Time.now-25.hours)
    step.is_finalized = false
    expect(step).to be_invalid
  end

  it 'can be unfinalized within 24 hours' do
    step = create(:project_group, is_finalized: true, finalized_at: Time.now-23.hours)
    step.is_finalized = false
    expect(step).to be_valid
  end

  it 'has finalized_at automatically assigned' do
    step = create(:project_group, is_finalized: false)
    expect(step.finalized_at).to be_nil
    step.update(is_finalized: true)
    expect(step.finalized_at).not_to be_nil
  end

  it 'has original_date automatically assigned' do
    step = create(:project_group, scheduled_date: Date.today, is_finalized: true)
    expect(step[:original_date]).to be_nil
    step.update(scheduled_date: Date.today + 2.days)
    # Beware, the 'orginal_date' method will automatically returned scheduled date even when the
    # raw value is nil, so need to directly check the attribute
    expect(step[:original_date]).not_to be_nil
  end

  context 'tree with no children' do
    subject(:group) { create(:project_group) }

    let(:step) { create(:project_step) }

    it 'can be destroyed' do
      group.destroy
    end

    it 'can have child steps' do
      group.add_child(step)

      expect(group.children.count).to eq 1
      expect(group.children.first).to eq step
    end
  end

  context 'tree with children' do
    let(:child_one) { create(:project_step) }
    let(:child_two) { create(:project_step) }

    subject(:group) do
      group = create(:project_group)
      group.add_child(child_one)
      group.add_child(child_two)

      group
    end

    it 'can not be destroyed' do
      expect{ group.destroy }.to raise_error ProjectGroup::DestroyWithChildrenError
    end
  end

end
