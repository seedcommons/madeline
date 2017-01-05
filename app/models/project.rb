class Project < ActiveRecord::Base
  include Translatable
  include OptionSettable

  belongs_to :division
  belongs_to :primary_agent, class_name: 'Person'
  belongs_to :secondary_agent, class_name: 'Person'

  # define accessor-like convenience methods for the fields stored in the Translations table
  attr_translatable :summary, :details

  validates :division_id, presence: true
end
