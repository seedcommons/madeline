require 'rails_helper'

RSpec.describe Timeline::DateAdjustment, type: :model do
  before { allow(Pundit).to receive(:authorize).and_return(true) }

  let(:user) { instance_double(User) }
  let(:direction) { 'forward' }
  let(:num_of_days) { 4 }
  let(:default_params) { { time_direction: direction, num_of_days: num_of_days } }

  let(:default_date) { Date.civil(2016, 9, 23) }

  context 'with one step' do
    let(:step) { create(:project_step, scheduled_start_date: default_date) }
    let(:steps) { [step.id] }

    context 'when moving forward' do
      it 'should move step forward' do
        Timeline::DateAdjustment.new(user, steps, default_params).perform

        step.reload
        expect(step.scheduled_start_date).to eq default_date + num_of_days
      end
    end

    context 'when moving backward' do
      let(:direction) { 'backward' }

      it 'should move step backward' do
        Timeline::DateAdjustment.new(user, steps, default_params).perform

        step.reload
        expect(step.scheduled_start_date).to eq default_date - num_of_days
      end
    end
  end

  context 'with multiple orphan steps' do
    let(:step1) { create(:project_step, scheduled_start_date: default_date) }
    let(:step2) { create(:project_step, scheduled_start_date: default_date) }
    let(:step3) { create(:project_step, scheduled_start_date: default_date) }
    let(:steps) { { step1: step1, step2: step2, step3: step3 } }

    context 'when moving forward' do
      [:step1, :step2, :step3].each  do |step_name|
        it "should move #{step_name} forward" do
          Timeline::DateAdjustment.new(user, steps.values.collect(&:id), default_params).perform

          step = steps[step_name]
          step.reload
          expect(step.scheduled_start_date).to eq default_date + num_of_days
        end
      end
    end

    context 'when moving backward' do
      let(:direction) { 'backward' }

      [:step1, :step2, :step3].each  do |step_name|
        it "should move #{step_name} backward" do
          Timeline::DateAdjustment.new(user, steps.values.collect(&:id), default_params).perform

          step = steps[step_name]
          step.reload
          expect(step.scheduled_start_date).to eq default_date - num_of_days
        end
      end
    end
  end

  context 'with one grandparent step' do
    let(:step) { create(:project_step, :with_schedule_tree, scheduled_start_date: default_date) }
    let(:step_level_2) { step.schedule_children.first }
    let(:step_level_3) { step_level_2.schedule_children.first }

    let(:steps) { [step.id, step_level_2.id, step_level_3.id] }

    context 'when moving forward' do
      before do
        Timeline::DateAdjustment.new(user, steps, default_params).perform
        step.reload
        step_level_2.reload
        step_level_3.reload
      end

      it 'should move step forward' do
        expect(step.scheduled_start_date).to eq default_date + num_of_days
      end

      it 'should move step_level_2 forward' do
        offset = num_of_days + step.scheduled_duration_days
        expect(step_level_2.scheduled_start_date).to eq default_date + offset + 1
      end

      it 'should move step_level_3 forward' do
        offset = num_of_days + step_level_2.scheduled_duration_days + step.scheduled_duration_days
        expect(step_level_3.scheduled_start_date).to eq default_date + offset + 2
      end
    end
  end

  context 'with a mixture of orphan and children steps' do
    let(:step) { create(:project_step, :with_schedule_tree, scheduled_start_date: default_date) }
    let(:step_level_2) { step.schedule_children.first }
    let(:step_level_3) { step_level_2.schedule_children.first }
    let(:orphan_step1) { create(:project_step, scheduled_start_date: default_date + 8) }
    let(:orphan_step2) { create(:project_step, scheduled_start_date: default_date + 9) }

    let(:steps) { [step.id, step_level_2.id, step_level_3.id, orphan_step1.id, orphan_step2.id] }

    context 'when moving forward' do
      before do
        Timeline::DateAdjustment.new(user, steps, default_params).perform
        step.reload
        step_level_2.reload
        step_level_3.reload
      end

      it 'should move step forward' do
        expect(step.scheduled_start_date).to eq default_date + num_of_days
      end

      it 'should move step_level_2 forward' do
        offset = num_of_days + step.scheduled_duration_days
        expect(step_level_2.scheduled_start_date).to eq default_date + offset + 1
      end

      it 'should move step_level_3 forward' do
        offset = num_of_days + step_level_2.scheduled_duration_days + step.scheduled_duration_days
        expect(step_level_3.scheduled_start_date).to eq default_date + offset + 2
      end

      it 'should move orphan step 1 forward' do
        expect(orphan_step1.scheduled_start_date).to eq default_date + 8
      end

      it 'should move orphan step 2 forward' do
        expect(orphan_step2.scheduled_start_date).to eq default_date + 9
      end
    end
  end
end
