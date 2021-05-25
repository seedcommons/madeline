class Note < ApplicationRecord
  include ::Translatable

  belongs_to :notable, polymorphic: true
  belongs_to :author, class_name: 'Person'

  delegate :division, :division=, to: :notable
  delegate :name, to: :author, prefix: true

  # define accessor like convenience methods for the fields stored in the Translations table
  translates :text

  validates :notable, presence: true
  validates :author, presence: true

  def name
    "#{notable.try(:name)} note"
  end

end
