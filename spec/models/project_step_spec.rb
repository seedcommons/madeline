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

  it 'scheduled_start_date is set to actual_end_date if nil' do
    actual_end_date = Date.civil(2012, 1, 4)

    step = create(:project_step, scheduled_start_date: nil, actual_end_date: nil)

    expect(step.scheduled_start_date).to be_nil
    expect(step.actual_end_date).to be_nil

    step.actual_end_date = actual_end_date
    step.save

    expect(step.scheduled_start_date).to eq actual_end_date
  end

  it 'scheduled_end_date is nil when scheduled_start_date is also nil' do
    step = create(:project_step, scheduled_start_date: nil, actual_end_date: nil)

    expect(step.scheduled_start_date).to be_nil
    expect(step.scheduled_end_date).to be_nil
  end

  it 'raises error if scheduled_end_date is nil and old_end_date is not nil' do
    step = create(:project_step,
      scheduled_start_date: nil,
      old_start_date: Date.civil(2011, 1, 2),
      actual_end_date: nil)

    expect { step.save }.to raise_error(ArgumentError)
  end

  describe '#original_end_date' do
    let(:default_start_date) { Date.civil(2012, 1, 4) }
    let(:default_old_date) { Date.civil(2012, 1, 9) }
    let(:default_params) do
      { scheduled_start_date: default_start_date,
        old_start_date: default_old_date,
        scheduled_duration_days: 0,
        old_duration_days: 0 }
    end

    it 'is nil when scheduled_start_day and old_start_date is nil' do
      step = create(:project_step, default_params.merge(scheduled_start_date: nil, old_start_date: nil))
      expect(step.original_end_date).to be_nil
    end

    it 'returns scheduled_start_date if old_start_date is nil' do
      step = create(:project_step, default_params.merge(old_start_date: nil))
      expect(step.original_end_date).to eq default_start_date
    end

    it 'returns old_start_date if scheduled_start_date is present' do
      step = create(:project_step, default_params)
      expect(step.original_end_date).to eq default_old_date
    end

    it 'returns old_start_date if scheduled_start_date is nil' do
      step = create(:project_step, default_params.merge(scheduled_start_date: nil))
      expect(step.original_end_date).to be_nil
    end

    it 'scheduled_duration_days is added when old_duration_days is zero' do
      step = create(:project_step, default_params.merge(scheduled_duration_days: 2))
      expect(step.original_end_date).to eq default_old_date + 2
    end

    it 'old_duration_days is added when not zero' do
      step = create(:project_step, default_params.merge(scheduled_duration_days: 2, old_duration_days: 5))
      expect(step.original_end_date).to eq default_old_date + 5
    end
  end

  describe '#best_end_date' do
    let(:default_start_date) { Date.civil(2014, 2, 6) }
    let(:default_actual_end_date) { Date.civil(2014, 2, 13) }
    let(:default_params) { { scheduled_start_date: default_start_date, actual_end_date: default_actual_end_date, scheduled_duration_days: 0 } }

    it 'returns actual_end_date when set' do
      step = create(:project_step, default_params)
      expect(step.display_end_date).to eq default_actual_end_date
    end

    it 'returns scheduled_end_date if actual_end_date is nil' do
      step = create(:project_step, default_params.merge(actual_end_date: nil))
      expect(step.display_end_date).to eq default_start_date
    end
  end

  context 'with finalized project_step' do
    let(:duration) { 3 }
    let(:step) { create(:project_step, scheduled_start_date: Time.zone.today, scheduled_duration_days: duration, is_finalized: true)}

    it 'has old_start_date automatically assigned' do
      expect(step.old_start_date).to be_nil
      step.scheduled_start_date = Time.zone.today + 2.days
      step.save

      expect(step.old_start_date).not_to be_nil
    end

    it 'has old_duration_days automatically assigned' do
      expect(step.old_duration_days).to eq 0

      step.scheduled_duration_days = 5
      step.save

      expect(step.old_duration_days).to eq duration
    end
  end

  context 'with unfinalized project_step' do
    let(:step) { create(:project_step, scheduled_duration_days: 3, is_finalized: false) }

    it 'old_start_date is not automatically assigned' do
      expect(step.old_start_date).to be_nil
      step.scheduled_start_date = Time.zone.today + 2.days
      step.save

      expect(step.old_start_date).to be_nil
    end

    it 'old_duration_days is not automatically assigned' do
      expect(step.old_duration_days).to eq 0

      step.scheduled_duration_days = 5
      step.save

      expect(step.old_duration_days).to eq 0
    end

    it 'returns 0 for pending_days_shifted' do
      expect(step.pending_days_shifted).to eq 0
    end
  end

  context 'step incomplete and scheduled_start_date changed' do
    let(:step) { create(:project_step, is_finalized: true, scheduled_start_date: Date.civil(2016, 5, 3)) }
    before { step.scheduled_start_date = Date.civil(2016, 5, 21) }

    it 'returns proper pending_days_shifted' do
      expect(step.pending_days_shifted).to eq 18
    end
  end

  context 'step about to be completed' do
    let(:step) { create(:project_step, is_finalized: true, scheduled_start_date: Date.civil(2016, 4, 19)) }
    before { step.actual_end_date = Date.civil(2016, 4, 21) }

    it 'returns proper pending_days_shifted' do
      expect(step.pending_days_shifted).to eq 2
    end
  end

  context 'completed step' do
    let(:step) do
      create(:project_step,
        is_finalized: true,
        scheduled_start_date: Date.civil(2016, 4, 19),
        actual_end_date: Date.civil(2016, 6, 28))
    end
    before { step.actual_end_date = Date.civil(2016, 7, 2) }

    it 'returns proper pending_days_shifted' do
      expect(step.pending_days_shifted).to eq 4
    end
  end

  context 'a group' do
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

  context 'with an orpan project_step' do
    subject(:step) { create(:project_step, scheduled_start_date: start_date, scheduled_duration_days: duration) }

    let(:new_step)   { create(:project_step) }
    let(:start_date) { Date.civil(2016, 3, 4) }
    let(:duration)   { 2 }

    context 'when parent is set to orphan step' do
      before do
        step.schedule_parent_id = new_step.id
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

    it 'scheduled_start_date can be changed' do
      step.scheduled_start_date = Date.civil(2016, 9, 21)
      step.save
      step.reload

      expect(step.scheduled_start_date).to eq Date.civil(2016, 9, 21)
    end
  end

  context 'with child project_step' do
    subject(:step) do
      create(:project_step, schedule_parent_id: parent_step.id, scheduled_duration_days: step_duration)
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

    it 'scheduled_start_date can be set to parent end' do
      step.scheduled_start_date = parent_end
      step.save
      step.reload

      expect(step.scheduled_start_date).to eq parent_end
    end

    it 'scheduled_start_date must match parent end' do
      expect { step.scheduled_start_date = parent_end + 29 }.to raise_error(ArgumentError)
    end

    context 'is orphaned' do
      before do
        step.schedule_parent_id = nil
        step.save
      end

      it 'has no schedule_parent_id' do
        expect(step.schedule_parent_id).to be_nil
      end

      it 'keeps scheduled_start_date' do
        expect(step.scheduled_start_date).to eq parent_end
      end

      it 'keeps scheduled_duration_days' do
        expect(step.scheduled_duration_days).to eq step_duration
      end

      it 'keeps scheduled_end_date' do
        expect(step.scheduled_end_date).to eq parent_end + step_duration
      end
    end
  end

  context 'with orphan project_step containing its children and grandchildren' do
    subject(:step) { create(:project_step, :with_schedule_tree) }

    let(:step_level_2) { step.schedule_children.first }
    let(:step_level_3) { step_level_2.schedule_children.first }

    it 'has no parent' do
      expect(step.schedule_parent).to be_nil
    end

    it 'has children' do
      expect(step.schedule_children.count).to eq 3
    end

    it 'has grand children' do
      expect(step.schedule_children.reduce(0) { |count, gc| count + gc.schedule_children.count }).to eq 9
    end

    it 'level 2 children start matches level 1 end' do
      expect(step_level_2.scheduled_start_date).to eq step.scheduled_end_date
    end

    it 'level 3 children start matches level 2 end' do
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

      it 'level 2 children start matches level 1 end' do
        expect(step_level_2.scheduled_start_date).to eq step.scheduled_end_date
      end

      it 'level 3 children start matches level 2 end' do
        expect(step_level_3.scheduled_start_date).to eq step_level_2.scheduled_end_date
      end
    end
  end
end
