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
    subject(:step) { create(:project_step, scheduled_start_date: start_date, scheduled_duration_days: duration) }

    let(:new_step) { create(:project_step) }
    let(:start_date) { Date.civil(2016, 3, 4) }
    let(:duration) { 2 }

    it 'can have schedule_ancestor' do
      step.schedule_ancestor = new_step
      step.save
      step.reload

      expect(step.schedule_ancestor_id).to eq new_step.id
    end

    it 'scheduled_end_date is correct' do
      expect(step.scheduled_end_date).to eq Date.civil(2016, 3, 6)
    end

    # it 'can have schedule_decendants' do
    #   step.schedule_decendant = new_step
    #   new_step.reload
    #
    #   expect(new_step.schedule_ancestor_id).to eq step.id
    # end
  end

  context 'linked project_step' do
    subject(:step) do
      create(:project_step, schedule_ancestor: ancestor_step)
    end

    let(:ancestor_step) { create(:project_step, scheduled_start_date: ancestor_start, scheduled_duration_days: ancestor_duration) }
    let(:ancestor_start) { Date.civil(2014, 5, 8) }
    let(:ancestor_end) { Date.civil(2014, 5, 13) }
    let(:ancestor_duration) { 5 }

    it 'has schedule_ancestor_id' do
      expect(step.schedule_ancestor_id).to eq ancestor_step.id
    end

    it 'inherits ancestor_end' do
      expect(step.scheduled_start_date).to eq ancestor_end
    end

    it 'sets scheduled_start_date attribute' do
      expect(step.attributes['scheduled_start_date']).to eq ancestor_end
    end

    # context 'with scheduled_start_date' do
    #   let(:start_date) { Date.civil(2016, 12, 25) }
    #
    #   subject(:step) { create(:project_step, scheduled_start_date: start_date) }
    #
    #   # Should this be an error, or just unset scheduled_start_date
    #   it 'scheduled_start_date is unset when schedule_ancestor is set' do
    #     expect(step.scheduled_start_date).to eq start_date
    #
    #     step.schedule_ancestor = ancestor_step
    #
    #     expect(step.scheduled_start_date).to eq ancestor_start
    #   end
    # end
  end

  # it 'should ensure duration when start date present'
  it 'end date should be present based on the duration'
  it 'removes ancestor when scheduled_start_date is set'
  it 'raises error when ancestor assigned and scheduled_start_date is set'
  it 'raises error when neither ancestor or scheduled_start_date is set'
end
