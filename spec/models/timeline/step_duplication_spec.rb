require 'rails_helper'

shared_examples_for 'a duplicated step' do |params|
  date_offset = params[:date_offset]

  it 'has original project' do
    expect(subject.project).to eq original.project
  end
  it 'has original agent' do
    expect(subject.agent).to eq original.agent
  end
  it 'has original step_type_value' do
    expect(subject.step_type_value).to eq original.step_type_value
  end
  it 'has original scheduled_start_date' do
    expect(subject.scheduled_start_date).to eq original.scheduled_start_date + date_offset
  end
  it "scheduled_duration_days is date_offset by #{date_offset} sec" do
    expect(subject.scheduled_duration_days).to eq original.scheduled_duration_days
  end
  it 'old_start_date is nil' do
    expect(subject.old_start_date).to be_nil
  end
  it 'actual_end_date is nil' do
    expect(subject.actual_end_date).to be_nil
  end
  it 'is_finalize is false' do
    expect(subject.is_finalized).to eq false
  end
  it 'schedule_parent is nil' do
    expect(subject.schedule_parent).to be_nil
  end
end

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

    it_should_behave_like 'a duplicated step', date_offset: 0.days
  end

  context 'when duplicated once daily' do
    let(:original) { create(:project_step) }
    let(:duplicate) do
      duplication = Timeline::StepDuplication.new(original)
      duplication.perform(default_params)
    end
    subject { duplicate.first }

    it_should_behave_like 'a duplicated step', date_offset: 1.day
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

      it_should_behave_like 'a duplicated step', date_offset: 1.day
    end

    context 'with second step' do
      subject { duplicate[1] }

      it_should_behave_like 'a duplicated step', date_offset: 2.days
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

      it_should_behave_like 'a duplicated step', date_offset: 1.week
    end

    context 'with second step' do
      subject { duplicate[1] }

      it_should_behave_like 'a duplicated step', date_offset: 2.weeks
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

      it_should_behave_like 'a duplicated step', date_offset: 1.month
    end

    context 'with second step' do
      subject { duplicate[1] }

      it_should_behave_like 'a duplicated step', date_offset: 2.months
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

      it_should_behave_like 'a duplicated step', date_offset: 1.month
    end

    context 'with second step' do
      subject { duplicate[1] }

      it_should_behave_like 'a duplicated step', date_offset: 2.months
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

      it_should_behave_like 'a duplicated step', date_offset: 1.day
    end

    context 'with second step' do
      subject { duplicate[1] }

      it_should_behave_like 'a duplicated step', date_offset: 2.days
    end
  end
end
