# == Schema Information
#
# Table name: timeline_entries
#
#  actual_end_date         :date
#  agent_id                :integer
#  created_at              :datetime         not null
#  date_change_count       :integer          default(0), not null
#  finalized_at            :datetime
#  id                      :integer          not null, primary key
#  is_finalized            :boolean
#  old_duration_days       :integer          default(0)
#  old_start_date          :date
#  parent_id               :integer
#  project_id              :integer
#  schedule_parent_id      :integer
#  scheduled_duration_days :integer          default(0)
#  scheduled_start_date    :date
#  step_type_value         :string
#  type                    :string           not null
#  updated_at              :datetime         not null
#
# Indexes
#
#  index_timeline_entries_on_agent_id    (agent_id)
#  index_timeline_entries_on_project_id  (project_id)
#
# Foreign Keys
#
#  fk_rails_8589af42f8  (agent_id => people.id)
#  fk_rails_af8b359300  (project_id => projects.id)
#  fk_rails_d21c3b610d  (parent_id => timeline_entries.id)
#  fk_rails_fe366670d0  (schedule_parent_id => timeline_entries.id)
#

require 'rails_helper'

describe ProjectStep, type: :model do
  it 'has a valid factory' do
    expect(create(:project_step)).to be_valid
  end

  it 'cannot have child steps' do
    step1, step2 = create_list(:project_step, 2)
    expect { step1.add_child(step2) }.to raise_error(ProjectStep::NoChildrenAllowedError)
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
    step.save!

    expect(step.scheduled_start_date).to eq actual_end_date
  end

  it 'scheduled_end_date is nil when scheduled_start_date is also nil' do
    step = create(:project_step, scheduled_start_date: nil, actual_end_date: nil)

    expect(step.scheduled_start_date).to be_nil
    expect(step.scheduled_end_date).to be_nil
  end

  it 'scheduled_start_date can be set to blank string when scheduled_start_date of schedule_parent is nil' do
    parent = create(:project_step, scheduled_start_date: nil)
    step = create(:project_step, schedule_parent: parent)

    step.scheduled_start_date = ''
    step.save!

    expect(step.scheduled_start_date).to be_nil
  end

  it 'raises error if scheduled_end_date is nil and old_end_date is not nil' do
    step = create(:project_step, scheduled_start_date: nil, old_start_date: Date.civil(2011, 1, 2),
      actual_end_date: nil)

    expect { step.save! }.to raise_error(ArgumentError)
  end

  describe 'original_end_date' do
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

  # display_end_date is the 'best known' end date -- actual_end_date if present, scheduled_end_date otherwise
  describe 'display_end_date' do
    let(:default_start_date) { Date.civil(2014, 2, 6) }
    let(:default_actual_end_date) { Date.civil(2014, 2, 13) }
    let(:default_params) { {
      scheduled_start_date: default_start_date,
      actual_end_date: default_actual_end_date,
      scheduled_duration_days: 0
    } }

    it 'returns actual_end_date when set' do
      step = create(:project_step, default_params)
      expect(step.display_end_date).to eq default_actual_end_date
    end

    it 'returns scheduled_end_date if actual_end_date is nil' do
      step = create(:project_step, default_params.merge(actual_end_date: nil))
      expect(step.display_end_date).to eq default_start_date
    end
  end

  # old_start_date and old_duration_days are for keeping track of the originally planned dates
  describe 'old_start_date and old_duration_days' do
    context 'with finalized project_step' do
      let(:duration) { 3 }
      let(:step) { create(:project_step,
        scheduled_start_date: Time.zone.today,
        scheduled_duration_days: duration,
        is_finalized: true)
      }

      it 'has old_start_date automatically assigned' do
        expect(step.old_start_date).to be_nil
        step.scheduled_start_date = Time.zone.today + 2.days
        step.save!

        expect(step.old_start_date).not_to be_nil
      end

      it 'has old_duration_days automatically assigned' do
        expect(step.old_duration_days).to eq 0

        step.scheduled_duration_days = 5
        step.save!

        expect(step.old_duration_days).to eq duration
      end
    end

    context 'with unfinalized project_step' do
      let(:step) { create(:project_step, scheduled_duration_days: 3, is_finalized: false) }

      it 'old_start_date is not automatically assigned' do
        expect(step.old_start_date).to be_nil
        step.scheduled_start_date = Time.zone.today + 2.days
        step.save!

        expect(step.old_start_date).to be_nil
      end

      it 'old_duration_days is not automatically assigned' do
        expect(step.old_duration_days).to eq 0

        step.scheduled_duration_days = 5
        step.save!

        expect(step.old_duration_days).to eq 0
      end

      it 'returns 0 for pending_days_shifted' do
        expect(step.pending_days_shifted).to eq 0
      end
    end
  end

  # pending_days_shifted is used for asking the user if they want to adjust other steps by a similar amount
  describe 'pending_days_shifted' do
    context 'with step incomplete and scheduled_start_date changed' do
      let(:step) { create(:project_step, is_finalized: true, scheduled_start_date: Date.civil(2016, 5, 3)) }
      before { step.scheduled_start_date = Date.civil(2016, 5, 21) }

      it 'returns proper pending_days_shifted' do
        expect(step.pending_days_shifted).to eq 18
      end
    end

    context 'with step about to be completed' do
      let(:step) { create(:project_step, is_finalized: true, scheduled_start_date: Date.civil(2016, 4, 19)) }
      before { step.actual_end_date = Date.civil(2016, 4, 21) }

      it 'returns proper pending_days_shifted' do
        expect(step.pending_days_shifted).to eq 2
      end
    end

    context 'with completed step' do
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
  end

  describe 'schedule_parent and schedule_children' do
    describe 'a step with no schedule_parent' do
      subject(:step) { create(:project_step, scheduled_start_date: start_date,
        scheduled_duration_days: duration) }
      let(:new_step) { create(:project_step) }
      let(:start_date) { Date.civil(2016, 3, 4) }
      let(:duration) { 2 }

      it 'scheduled_end_date is correct' do
        expect(step.scheduled_end_date).to eq Date.civil(2016, 3, 6)
      end

      it 'scheduled_start_date can be changed' do
        step.scheduled_start_date = Date.civil(2016, 9, 21)
        step.save!
        step.reload
        expect(step.scheduled_start_date).to eq Date.civil(2016, 9, 21)
      end

      context 'when schedule_parent is set' do
        before do
          step.schedule_parent_id = new_step.id
          step.save!
          step.reload
        end

        it 'updates the scheduled_start_date' do
          expect(step.scheduled_start_date).to eq new_step.scheduled_end_date
        end
      end
    end

    describe 'a step with a schedule_parent' do
      subject(:step) do
        create(:project_step, schedule_parent_id: parent_step.id, scheduled_duration_days: step_duration)
      end

      let(:step_duration) { 3 }
      let(:parent_step) { create(:project_step, scheduled_start_date: parent_start,
        scheduled_duration_days: parent_duration) }
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
        step.save!
        step.reload

        expect(step.scheduled_start_date).to eq parent_end
      end

      it 'scheduled_start_date must match parent end' do
        step.scheduled_start_date = parent_end + 29
        expect(step).to_not be_valid
      end

      context 'when step is orphaned' do
        before do
          step.schedule_parent_id = nil
          step.save!
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

    describe 'a step with a child and grandchild' do
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

      describe 'cascading date adjustment' do
        let(:offset_days) { 5 }
        let!(:original_end_date) { step.scheduled_end_date }

        shared_examples_for "children dates are correct" do
          it 'level 1 display_end_date is updated by the expected offset' do
            expect(step.display_end_date).to eq original_end_date + offset_days
          end

          it 'level 2 children start matches level 1 end' do
            expect(step_level_2.display_start_date).to eq step.display_end_date
          end

          it 'level 3 children start matches level 2 end' do
            expect(step_level_3.display_start_date).to eq step_level_2.display_end_date
          end
        end

        context 'level 1 scheduled_start_date is updated' do
          before do
            step.scheduled_start_date += offset_days
            save_and_reload_steps
          end

          it_behaves_like "children dates are correct"
        end

        context 'level 1 duration is updated' do
          before do
            step.scheduled_duration_days += offset_days
            save_and_reload_steps
          end

          it_behaves_like "children dates are correct"
        end

        context 'level 1 actual_end_date is set' do
          before do
            step.actual_end_date = step.scheduled_end_date + offset_days
            save_and_reload_steps
          end

          it_behaves_like "children dates are correct"
        end

        context 'level 1 actual_end_date is set and then scheduled duration is changed' do
          before do
            step.actual_end_date = step.scheduled_end_date + offset_days

            # Changing the scheduled duration should be meaningless at this point because
            # the actual_end_date is set.
            step.scheduled_duration_days = 50

            save_and_reload_steps
          end

          it_behaves_like "children dates are correct"
        end

        def save_and_reload_steps
          step.save!
          step.reload
          step_level_2.reload
          step_level_3.reload
        end
      end
    end
  end
end
