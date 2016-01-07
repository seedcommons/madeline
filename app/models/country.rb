class Country < ActiveRecord::Base

  # create_table :countries do |t|
  #   t.string :name
  #   t.string :iso_code, limit: 2  ## todo: consider renaming this to just 'code'
  #   t.references :default_currency, references: :currencies
  #   t.references :default_language, references: :languages
  #   t.timestamps null: false


  belongs_to :default_language, class_name: 'Language'
  belongs_to :default_currency, class_name: 'Currency'

  #JE todo use cached map
  def self.id_from_name(name)
    Country.where(name: name).pluck(:id).first
  end


end
