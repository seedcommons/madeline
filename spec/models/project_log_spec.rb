# == Schema Information
#
# Table name: project_logs
#
#  agent_id              :integer
#  created_at            :datetime         not null
#  date                  :date
#  date_changed_to       :date
#  id                    :integer          not null, primary key
#  progress_metric_value :string
#  project_step_id       :integer
#  updated_at            :datetime         not null
#
# Indexes
#
#  index_project_logs_on_agent_id         (agent_id)
#  index_project_logs_on_project_step_id  (project_step_id)
#
# Foreign Keys
#
#  fk_rails_54dbbbb1d4  (agent_id => people.id)
#  fk_rails_67bf2c0e5e  (project_step_id => timeline_entries.id)
#

require 'rails_helper'

describe ProjectLog, :type => :model do
  it 'has a valid factory' do
    expect(create(:project_log)).to be_valid
  end
end
