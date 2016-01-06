class Translation < ActiveRecord::Base

  # create_table :translations do |t|
  #   t.references :translatable, polymorphic: true, index: true
  #   t.string :translatable_attribute
  #   t.references :language, index: true
  #   t.text :text
  #   t.boolean :is_primary
  #   t.boolean :is_dirty
  #
  #   t.timestamps


  belongs_to :translatable, polymorphic: true
  belongs_to :language

end
