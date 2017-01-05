# == Schema Information
#
# Table name: basic_projects
#
#  created_at         :datetime         not null
#  division_id        :integer
#  id                 :integer          not null, primary key
#  primary_agent_id   :integer
#  project_type_value :string
#  secondary_agent_id :integer
#  start_date         :date
#  status_value       :string
#  target_end_date    :date
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_basic_projects_on_division_id         (division_id)
#  index_basic_projects_on_primary_agent_id    (primary_agent_id)
#  index_basic_projects_on_secondary_agent_id  (secondary_agent_id)
#
# Foreign Keys
#
#  fk_rails_178e060fbf  (primary_agent_id => people.id)
#  fk_rails_b395d6bd95  (division_id => divisions.id)
#  fk_rails_bfc2b8df08  (secondary_agent_id => people.id)
#

class BasicProject < Project
end
