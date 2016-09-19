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

    let(:new_step)   { create(:project_step) }
    let(:start_date) { Date.civil(2016, 3, 4) }
    let(:duration)   { 2 }

    context 'when linked' do
      before do
        step.schedule_parent = new_step
        step.save
        step.reload
      end

      it 'updates the scheduled_start_date' do
        expect(step.scheduled_start_date).to eq new_step.scheduled_end_date
      end
    end

    it 'scheduled_end_date is correct' do
      expect(step.scheduled_end_date).to eq Date.civil(2016, 3, 6)
    end
  end

  context 'with linked project_step' do
    subject(:step) do
      create(:project_step, schedule_parent: parent_step, scheduled_duration_days: step_duration)
    end

    let(:step_duration) { 3 }
    let(:parent_step) { create(:project_step, scheduled_start_date: parent_start, scheduled_duration_days: parent_duration) }
    let(:parent_start) { Date.civil(2014, 5, 8) }
    let(:parent_end) { Date.civil(2014, 5, 13) }
    let(:parent_duration) { 5 }

    it 'has schedule_parent_id' do
      expect(step.schedule_parent_id).to eq parent_step.id
    end

    it 'inherits parent_end for scheduled_start_date' do
      expect(step.scheduled_start_date).to eq parent_end
    end

    it 'updates scheduled_end_date' do
      expect(step.scheduled_end_date).to eq parent_end + 3
    end

    context 'is unlinked' do
      before do
        step.schedule_parent = nil
        step.save
      end

      it 'has no schedule_parent_id' do
        expect(step.schedule_parent_id).to be_nil
      end

      it 'keeps scheduled_start_date' do
        expect(step.scheduled_start_date).to eq parent_end
      end

      it 'keeps scheduled_end_date' do
        expect(step.scheduled_end_date).to eq parent_end + step_duration
      end
    end
  end

  context 'with linked project_step chain' do
    subject(:step) { create(:project_step, :with_schedule_tree) }

    let(:step_level_2) { step.schedule_children.first }
    let(:step_level_3) { step_level_2.schedule_children.first }

    it 'has children' do
      expect(step.schedule_children.count).to eq 3
    end

    it 'level 2 children start matches level 1 start' do
      expect(step_level_2.scheduled_start_date).to eq step.scheduled_end_date
    end

    it 'level 3 children start matches level 2 start' do
      expect(step_level_3.scheduled_start_date).to eq step_level_2.scheduled_end_date
    end

    context 'and level 1 scheduled_start_date is updated' do
      let(:duration_offset) { 5 }
      before do
        @original_date = step.scheduled_start_date

        step.scheduled_start_date += duration_offset
        step.save

        step.reload
        step_level_2.reload
        step_level_3.reload
      end

      it 'level 1 scheduled_start_date is updated' do
        expect(step.scheduled_start_date).to eq @original_date + duration_offset
      end

      it 'level 2 children start matches level 1 start' do
        expect(step_level_2.scheduled_start_date).to eq step.scheduled_end_date
      end

      it 'level 3 children start matches level 2 start' do
        expect(step_level_3.scheduled_start_date).to eq step_level_2.scheduled_end_date
      end
    end
  end
end
