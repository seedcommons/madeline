# == Schema Information
#
# Table name: projects
#
#  amount                      :decimal(, )
#  created_at                  :datetime         not null
#  currency_id                 :integer
#  custom_data                 :json
#  division_id                 :integer
#  end_date                    :date
#  first_interest_payment_date :date
#  first_payment_date          :date
#  id                          :integer          not null, primary key
#  length_months               :integer
#  loan_type_value             :string
#  name                        :string
#  organization_id             :integer
#  primary_agent_id            :integer
#  projected_return            :decimal(, )
#  public_level_value          :string
#  rate                        :decimal(, )
#  representative_id           :integer
#  secondary_agent_id          :integer
#  signing_date                :date
#  status_value                :string
#  type                        :string           not null
#  updated_at                  :datetime         not null
#
# Indexes
#
#  index_projects_on_currency_id      (currency_id)
#  index_projects_on_division_id      (division_id)
#  index_projects_on_organization_id  (organization_id)
#
# Foreign Keys
#
#  fk_rails_5a4bc9458a  (division_id => divisions.id)
#  fk_rails_7a8d917bd9  (secondary_agent_id => people.id)
#  fk_rails_ade0930898  (currency_id => currencies.id)
#  fk_rails_dc1094f4ed  (organization_id => organizations.id)
#  fk_rails_ded298065b  (representative_id => people.id)
#  fk_rails_e90f6505d8  (primary_agent_id => people.id)
#

class Project < ActiveRecord::Base
  include Translatable
  include OptionSettable

  # Status values can be found at Loan.status_option_set.options and
  # BasicProject.status_option_set.options
  OPEN_STATUSES = %w(active changed possible prospective)

  belongs_to :division
  belongs_to :primary_agent, class_name: 'Person'
  belongs_to :secondary_agent, class_name: 'Person'
  has_many :timeline_entries, dependent: :destroy
  has_many :project_logs, through: :timeline_entries
  has_many :transactions, class_name: 'Accounting::Transaction'

  # define accessor-like convenience methods for the fields stored in the Translations table
  attr_translatable :summary, :details

  validates :division_id, presence: true

  alias_method :logs, :project_logs

  # The Loan's timeline entries should be accessed via this root node.
  # Timeline steps are organzed as a tree. The tree has a blank root node (ProjectGroup) that is not shown
  # to the user, but makes it easier to do computations over the tree (instead of each top level group
  # being the root of its own separate tree).
  # May return nil if there are no groups or steps in the loan thus far.
  def root_timeline_entry
    @root_timeline_entry ||= timeline_entries.find_or_create_by(parent_id: nil, type: "ProjectGroup")
  end

  def timeline_groups_preordered
    root_timeline_entry.self_and_descendant_groups_preordered
  end

  # DEPRECATED - This should not be necessary once we transition to tabular format.
  # Do regular ruby select, to avoid issues with AR caching
  # Note, this means the method returns an array, not an AR::Relation
  def project_steps
    timeline_entries.order(:scheduled_start_date).select { |e| e.type == 'ProjectStep' }
  end

  def display_name
    return '' if new_record?
    name.blank? ? default_name : name
  end

  # creates / reuses a default step when migrating ProjectLogs without a proper owning step
  # beware, not at all optimized, but sufficient for migration.
  # not sure if this will be useful beyond migration.  if so, perhaps worth better optimizing,
  # if not, can remove once we're past the production migration process
  def default_step
    step = project_steps.select{|s| s.summary == DEFAULT_STEP_NAME}.first
    unless step
      # Could perhaps optimize this with a 'find_or_create_by', but would be tricky with the translatable 'summary' field,
      # and it's nice to be able to log the operation.
      logger.info {"default step not found for loan[#{id}] - creating"}

      step = ProjectStep.new(project: self)
      step.update(summary: DEFAULT_STEP_NAME)
    end
    step
  end

  def agent_names
    [primary_agent.try(:name), secondary_agent.try(:name)].compact
  end

  def display_agent_names
    agent_names.join(', ')
  end

  def calendar_events
    CalendarEvent.build_for(self)
  end

  def project_events(order_by = "Completed IS NULL OR Completed = '0000-00-00', Completed, Date")
    @project_events ||= ProjectEvent.includes(project_logs: :progress_metric).
      where("lower(ProjectTable) = 'projects' and ProjectID = ?", self.ID).order(order_by)
    @project_events.reject do |p|
      # Hide past uncompleted project events without logs (for now)
      !p.completed && p.project_logs.empty? && p.date <= Date.today
    end
  end

  def health_status_available?
    return false
  end

  def self.dashboard_order(person_id)
    clauses = []

    clauses << "CASE WHEN projects.primary_agent_id = #{person_id} THEN 1"\
                    "WHEN projects.secondary_agent_id = #{person_id} THEN 2 END"

    clauses << "CASE projects.status_value WHEN 'active' THEN 1 WHEN 'prospective'"\
                    "THEN 2 ELSE 3 END"

    clauses << "CASE projects.type WHEN 'Loan' THEN 1 WHEN 'BasicProject' THEN 2 END"

    clauses.join(', ')
  end
end
