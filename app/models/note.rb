class Note < ActiveRecord::Base
  include ::Translatable

  # create_table :notes do |t|
  #   t.references :notable, polymorphic: true, index: true
  #   t.references :person, index: true
  #   t.timestamps


  belongs_to :notable, polymorphic: true
  belongs_to :person

  # define accessor like convenience methods for the fields stored in the Translations table
  attr_translatable :text


  def name
    "#{notable.try(:name)} note"
  end

end
