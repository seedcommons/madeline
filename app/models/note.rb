# == Schema Information
#
# Table name: notes
#
#  id           :integer          not null, primary key
#  notable_id   :integer
#  notable_type :string
#  author_id    :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_notes_on_author_id                    (author_id)
#  index_notes_on_notable_type_and_notable_id  (notable_type,notable_id)
#

class Note < ActiveRecord::Base
  include ::Translatable

  belongs_to :notable, polymorphic: true
  belongs_to :author, class_name: 'Person'

  delegate :division, :division=, to: :notable

  # define accessor like convenience methods for the fields stored in the Translations table
  attr_translatable :text

  validates :notable, presence: true
  validates :author, presence: true

  def name
    "#{notable.try(:name)} note"
  end

end
