require 'rails_helper'

describe TimelineEntry, type: :model do

  context 'primary and secondary agents' do
    let(:tle_1) { build(:project_step, scheduled_duration_days: 0) }
    let(:tle_2) { build(:project_step) }

    it 'raises error if duration is less than 1 day' do
      expect(tle_1).not_to be_valid
      expect(tle_1.errors[:scheduled_end_date].join).to match("Duration days can't be less than 1")
    end

    it 'does not raise error for valid entries' do
      expect(tle_2).to be_valid
    end
  end
end
