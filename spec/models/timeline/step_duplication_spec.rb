require 'rails_helper'

RSpec.describe Timeline::StepDuplication, type: :model do
  let(:repeat_duration) { 'custom_repeat' }
  let(:time_unit_frequency) { '1' }
  let(:time_unit) { 'days' }
  let(:end_occurrence_type) { 'count' }
  let(:num_of_occurrences) { '1' }
  let(:default_params) do
    { repeat_duration: repeat_duration,
      time_unit_frequency: time_unit_frequency,
      time_unit: time_unit,
      end_occurrence_type: end_occurrence_type,
      num_of_occurrences: num_of_occurrences }
  end

  context 'when duplicated once' do
    let(:original) { create(:project_step) }
    let(:duplicate) { Timeline::StepDuplication.new(original).perform(repeat_duration: 'once') }
    subject { duplicate.first }

    it { expect(subject.project).to eq original.project }
    it { expect(subject.agent).to eq original.agent }
    it { expect(subject.step_type_value).to eq original.step_type_value }
    it { expect(subject.scheduled_start_date).to eq original.scheduled_start_date }
    it { expect(subject.scheduled_duration_days).to eq original.scheduled_duration_days }
    it { expect(subject.original_date).to be_nil }
    it { expect(subject.completed_date).to be_nil }
    it { expect(subject.is_finalized).to eq false }
    it { expect(subject.schedule_parent).to be_nil }
  end

  context 'when duplicated once daily' do
    let(:original) { create(:project_step) }
    let(:duplicate) do
      duplication = Timeline::StepDuplication.new(original)
      duplication.perform(default_params)
    end
    subject { duplicate.first }

    it { expect(subject.project).to eq original.project }
    it { expect(subject.agent).to eq original.agent }
    it { expect(subject.step_type_value).to eq original.step_type_value }
    it { expect(subject.scheduled_start_date).to eq original.scheduled_start_date + 1 }
    it { expect(subject.original_date).to be_nil }
    it { expect(subject.completed_date).to be_nil }
    it { expect(subject.scheduled_duration_days).to eq original.scheduled_duration_days }
    it { expect(subject.is_finalized).to eq false }
    it { expect(subject.schedule_parent).to be_nil }
  end

  context 'when duplicated twice daily' do
    let(:original) { create(:project_step) }
    let(:num_of_occurrences) { '2' }
    let(:duplicate) do
      duplication = Timeline::StepDuplication.new(original)
      duplication.perform(default_params)
    end

    it 'should create 2 duplicates' do
      expect(duplicate.count).to eq 2
    end

    context 'with first step' do
      subject { duplicate.first }

      it { expect(subject.project).to eq original.project }
      it { expect(subject.agent).to eq original.agent }
      it { expect(subject.step_type_value).to eq original.step_type_value }
      it { expect(subject.scheduled_start_date).to eq original.scheduled_start_date + 1 }
      it { expect(subject.original_date).to be_nil }
      it { expect(subject.completed_date).to be_nil }
      it { expect(subject.scheduled_duration_days).to eq original.scheduled_duration_days }
      it { expect(subject.is_finalized).to eq false }
      it { expect(subject.schedule_parent).to be_nil }
    end

    context 'with second step' do
      subject { duplicate[1] }

      it { expect(subject.project).to eq original.project }
      it { expect(subject.agent).to eq original.agent }
      it { expect(subject.step_type_value).to eq original.step_type_value }
      it { expect(subject.scheduled_start_date).to eq original.scheduled_start_date + 2 }
      it { expect(subject.original_date).to be_nil }
      it { expect(subject.completed_date).to be_nil }
      it { expect(subject.scheduled_duration_days).to eq original.scheduled_duration_days }
      it { expect(subject.is_finalized).to eq false }
      it { expect(subject.schedule_parent).to be_nil }
    end
  end

  context 'when duplicated twice weekly' do
    let(:original) { create(:project_step) }
    let(:num_of_occurrences) { '2' }
    let(:time_unit) { 'weeks' }
    let(:duplicate) do
      duplication = Timeline::StepDuplication.new(original)
      duplication.perform(default_params)
    end

    it 'should create 2 duplicates' do
      expect(duplicate.count).to eq 2
    end

    context 'with first step' do
      subject { duplicate.first }

      it { expect(subject.project).to eq original.project }
      it { expect(subject.agent).to eq original.agent }
      it { expect(subject.step_type_value).to eq original.step_type_value }
      it { expect(subject.scheduled_start_date).to eq original.scheduled_start_date + 1.week }
      it { expect(subject.original_date).to be_nil }
      it { expect(subject.completed_date).to be_nil }
      it { expect(subject.scheduled_duration_days).to eq original.scheduled_duration_days }
      it { expect(subject.is_finalized).to eq false }
      it { expect(subject.schedule_parent).to be_nil }
    end

    context 'with second step' do
      subject { duplicate[1] }

      it { expect(subject.project).to eq original.project }
      it { expect(subject.agent).to eq original.agent }
      it { expect(subject.step_type_value).to eq original.step_type_value }
      it { expect(subject.scheduled_start_date).to eq original.scheduled_start_date + 2.weeks }
      it { expect(subject.original_date).to be_nil }
      it { expect(subject.completed_date).to be_nil }
      it { expect(subject.scheduled_duration_days).to eq original.scheduled_duration_days }
      it { expect(subject.is_finalized).to eq false }
      it { expect(subject.schedule_parent).to be_nil }
    end
  end

  context 'when duplicated twice monthly' do
    let(:original) { create(:project_step, scheduled_start_date: Date.civil(2016, 3, 18)) }
    let(:num_of_occurrences) { '2' }
    let(:time_unit) { 'months' }
    let(:duplicate) do
      duplication = Timeline::StepDuplication.new(original)
      duplication.perform(default_params.merge('month_repeat_on': '18th day'))
    end

    it 'should create 2 duplicates' do
      expect(duplicate.count).to eq 2
    end

    context 'with first step' do
      subject { duplicate.first }

      it { expect(subject.project).to eq original.project }
      it { expect(subject.agent).to eq original.agent }
      it { expect(subject.step_type_value).to eq original.step_type_value }
      it { expect(subject.scheduled_start_date).to eq original.scheduled_start_date + 1.month }
      it { expect(subject.original_date).to be_nil }
      it { expect(subject.completed_date).to be_nil }
      it { expect(subject.scheduled_duration_days).to eq original.scheduled_duration_days }
      it { expect(subject.is_finalized).to eq false }
      it { expect(subject.schedule_parent).to be_nil }
      it { expect(subject.schedule_parent).to be_nil }
    end

    context 'with second step' do
      subject { duplicate[1] }

      it { expect(subject.project).to eq original.project }
      it { expect(subject.agent).to eq original.agent }
      it { expect(subject.step_type_value).to eq original.step_type_value }
      it { expect(subject.scheduled_start_date).to eq original.scheduled_start_date + 2.months }
      it { expect(subject.original_date).to be_nil }
      it { expect(subject.completed_date).to be_nil }
      it { expect(subject.is_finalized).to eq false }
      it { expect(subject.schedule_parent).to be_nil }
    end
  end

  context 'when duplicated monthly into future' do
    let(:original) { create(:project_step, scheduled_start_date: Date.civil(2016, 3, 10)) }
    let(:num_of_occurrences) { '2' }
    let(:time_unit) { 'months' }
    let(:duplicate) do
      params = default_params.merge('month_repeat_on': '10th day', 'end_occurrence_type': 'date', 'end_date': '2016-05-30')
      duplication = Timeline::StepDuplication.new(original)
      duplication.perform(params)
    end

    it 'should create 2 duplicates' do
      expect(duplicate.count).to eq 2
    end

    context 'with first step' do
      subject { duplicate.first }

      it { expect(subject.project).to eq original.project }
      it { expect(subject.agent).to eq original.agent }
      it { expect(subject.step_type_value).to eq original.step_type_value }
      it { expect(subject.scheduled_start_date).to eq original.scheduled_start_date + 1.month }
      it { expect(subject.original_date).to be_nil }
      it { expect(subject.completed_date).to be_nil }
      it { expect(subject.scheduled_duration_days).to eq original.scheduled_duration_days }
      it { expect(subject.is_finalized).to eq false }
      it { expect(subject.schedule_parent).to be_nil }
    end

    context 'with second step' do
      subject { duplicate[1] }

      it { expect(subject.project).to eq original.project }
      it { expect(subject.agent).to eq original.agent }
      it { expect(subject.step_type_value).to eq original.step_type_value }
      it { expect(subject.scheduled_start_date).to eq original.scheduled_start_date + 2.months }
      it { expect(subject.original_date).to be_nil }
      it { expect(subject.completed_date).to be_nil }
      it { expect(subject.scheduled_duration_days).to eq original.scheduled_duration_days }
      it { expect(subject.is_finalized).to eq false }
      it { expect(subject.schedule_parent).to be_nil }
    end
  end

  context 'when 3-day long child step is duplicated twice daily' do
    let(:original_parent) { create(:project_step, :with_children, scheduled_start_date: Date.civil(2016, 3, 18), scheduled_duration_days: 3) }
    let(:original) { original_parent.schedule_children.first }
    let(:num_of_occurrences) { '2' }
    let(:time_unit) { 'days' }
    let(:duplicate) do
      duplication = Timeline::StepDuplication.new(original)
      duplication.perform(default_params)
    end

    it 'should create 2 duplicates' do
      expect(duplicate.count).to eq 2
    end

    context 'with first step' do
      subject { duplicate.first }

      it { expect(subject.project).to eq original.project }
      it { expect(subject.agent).to eq original.agent }
      it { expect(subject.step_type_value).to eq original.step_type_value }
      it { expect(subject.scheduled_start_date).to eq original.scheduled_start_date + 1.day }
      it { expect(subject.original_date).to be_nil }
      it { expect(subject.completed_date).to be_nil }
      it { expect(subject.scheduled_duration_days).to eq original.scheduled_duration_days }
      it { expect(subject.is_finalized).to eq false }
      it { expect(subject.schedule_parent).to be_nil }
    end

    context 'with second step' do
      subject { duplicate[1] }

      it { expect(subject.project).to eq original.project }
      it { expect(subject.agent).to eq original.agent }
      it { expect(subject.step_type_value).to eq original.step_type_value }
      it { expect(subject.scheduled_start_date).to eq original.scheduled_start_date + 2.days }
      it { expect(subject.original_date).to be_nil }
      it { expect(subject.completed_date).to be_nil }
      it { expect(subject.scheduled_duration_days).to eq original.scheduled_duration_days }
      it { expect(subject.is_finalized).to eq false }
      it { expect(subject.schedule_parent).to be_nil }
    end
  end
end
