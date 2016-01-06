class ProjectStep < ActiveRecord::Base
  include ::Translatable

  #keeping these for now since i find it provides a useful reference
  #but expect to switch to the annotate_models gem at some point in the future
  #
  # create_table :project_steps do |t|
  #   t.references :project, polymorphic: true, index: true
  #   t.references :person, index: true
  #   t.date :scheduled_date
  #   t.date :completed_date
  #   t.boolean :is_finalized
  #   t.integer :type_option_id
  #   t.timestamps

  belongs_to :project, polymorphic: true
  belongs_to :person


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
