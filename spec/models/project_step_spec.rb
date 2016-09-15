require 'rails_helper'

describe ProjectStep, type: :model do
  it_should_behave_like 'translatable', ['summary', 'details']
  it_should_behave_like 'option_settable', ['step_type']

  it 'has a valid factory' do
    expect(create(:project_step)).to be_valid
  end

  it 'can not be unfinalized after 24 hours' do
    step = create(:project_step, is_finalized: true, finalized_at: Time.now - 25.hours)
    step.is_finalized = false
    expect(step).to be_invalid
  end

  it 'can be unfinalized within 24 hours' do
    step = create(:project_step, is_finalized: true, finalized_at: Time.now - 23.hours)
    step.is_finalized = false
    expect(step).to be_valid
  end

  it 'has finalized_at automatically assigned' do
    step = create(:project_step, is_finalized: false)
    expect(step.finalized_at).to be_nil
    step.update(is_finalized: true)
    expect(step.finalized_at).not_to be_nil
  end

  it 'has original_date automatically assigned' do
    step = create(:project_step, scheduled_start_date: Date.today, is_finalized: true)
    expect(step[:original_date]).to be_nil
    step.update(scheduled_start_date: Date.today + 2.days)
    # Beware, the 'orginal_date' method will automatically returned scheduled date even when the
    # raw value is nil, so need to directly check the attribute
    expect(step[:original_date]).not_to be_nil
  end

  context 'groups' do
    subject(:step) { create(:project_step) }

    let(:new_step) { create(:project_step) }
    let(:group) { create(:project_group) }

    it 'cannot have child steps' do
      expect { step.add_child(new_step) }.to raise_error(ProjectStep::NoChildrenAllowedError)
    end

    it 'can be added to a group' do
      group.add_child(step)

      expect(group.children.count).to eq 1
    end
  end

  context 'unlinked project_step' do
    subject(:step) { create(:project_step) }

    let(:new_step) { create(:project_step) }

    it 'can have schedule_ancestor' do
      step.schedule_ancestor = new_step
      step.save
      step.reload

      expect(step.schedule_ancestor_id).to eq new_step.id
    end

    it 'can have schedule_decendant' do
      step.schedule_decendant = new_step
      new_step.reload

      expect(new_step.schedule_ancestor_id).to eq step.id
    end
  end

  context 'linked project_step' do
    subject(:step) do
      create(:project_step, schedule_ancestor: ancestor_step)
    end

    let(:ancestor_start) { Date.civil(2014, 5, 8) }
    let(:ancestor_step) { create(:project_step, scheduled_start_date: ancestor_start) }

    it 'has schedule_ancestor_id' do
      expect(step.schedule_ancestor_id).to eq ancestor_step.id
    end

    it 'inherits ancestor_start' do
      expect(stp.scheduled_start_date).to eq ancestor_start
    end

    it 'unsets scheduled_start_date attribute' do
      expect(step.attributes[:scheduled_start_date]).to be_nil
    end

  end

  # it 'should ensure duration when start date present'
  it 'end date should be present based on the duration'
  it 'removes ancestor when scheduled_start_date is set'
  it 'raises error when ancestor assigned and scheduled_start_date is set'
  it 'raises error when neither ancestor or scheduled_start_date is set'
end
