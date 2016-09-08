# == Schema Information
#
# Table name: timeline_entries
#
#  agent_id          :integer
#  completed_date    :date
#  created_at        :datetime         not null
#  date_change_count :integer          default(0), not null
#  finalized_at      :datetime
#  id                :integer          not null, primary key
#  is_finalized      :boolean
#  original_date     :date
#  project_id        :integer
#  project_type      :string
#  scheduled_date    :date
#  step_type_value   :string
#  type              :string
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_timeline_entries_on_agent_id                     (agent_id)
#  index_timeline_entries_on_project_type_and_project_id  (project_type,project_id)
#
# Foreign Keys
#
#  fk_rails_8589af42f8  (agent_id => people.id)
#

require 'chronic'
class ProjectStep < TimelineEntry

end
