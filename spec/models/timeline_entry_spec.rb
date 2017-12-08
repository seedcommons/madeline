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
#  scheduled_duration_days :integer
#  scheduled_start_date    :date
#  step_type_value         :string           not null
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
#  fk_rails_...  (agent_id => people.id)
#  fk_rails_...  (parent_id => timeline_entries.id)
#  fk_rails_...  (project_id => projects.id)
#  fk_rails_...  (schedule_parent_id => timeline_entries.id)
#

require 'rails_helper'

describe TimelineEntry, type: :model do

  context 'primary and secondary agents' do
    let(:tle_1) { build(:project_step, scheduled_duration_days: 0) }
    let(:tle_2) { build(:project_step) }

    it 'raises error if duration is less than 1 day' do
      error = 'The scheduled duration of a step cannot be less than 1 day'
      expect(tle_1).not_to be_valid
      expect(tle_1.errors[:scheduled_end_date].join).to match(error)
    end

    it 'does not raise error for valid entries' do
      expect(tle_2).to be_valid
    end
  end
end
