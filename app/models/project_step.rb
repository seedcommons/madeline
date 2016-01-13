# == Schema Information
#
# Table name: project_steps
#
#  id             :integer          not null, primary key
#  project_id     :integer
#  project_type   :string
#  agent_id       :integer
#  scheduled_date :date
#  completed_date :date
#  is_finalized   :boolean
#  type_option_id :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_project_steps_on_agent_id                     (agent_id)
#  index_project_steps_on_project_type_and_project_id  (project_type,project_id)
#

class ProjectStep < ActiveRecord::Base
  include ::Translatable

  belongs_to :project, polymorphic: true
  belongs_to :agent, class_name: 'Person'


  has_many :project_logs


  # define accessor like convenience methods for the fields stored in the Translations table
  attr_translatable :summary, :details


  validates :project_id, presence: true


  def name
    # logger.debug "this: #{self.inspect}"
    "#{project.try(:name)} step"
  end

  def logs_count
    project_logs.count
  end


  TYPE_OPTIONS = OptionSet.new(
      [ [1, 'Step'],
        [2, 'Milestone'],
        [9, 'Agenda']  # legacy data exists of type 'agenda', but not expecting to carry this forward into the new system
      ]
  )

  MIGRATION_TYPE_OPTIONS = OptionSet.new(
      [ [1, 'Paso'],
        [9, 'Agenda'],
      ]
  )


  def completed_or_not
    self.completed_date ? 'completed' : 'not_completed'
  end

  def completed?
    self.completed_date?
  end

  def status
    if self.completed
      I18n.t :log_completed
    else
      project_logs.order(:date).last.try(:progress)
    end
  end

  def display_date
    I18n.l (self.completed_date || self.scheduled_date), format: :long
  end
end
