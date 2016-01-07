class Country < ActiveRecord::Base
  belongs_to :default_language, class_name: 'Language'
  belongs_to :default_currency, class_name: 'Currency'

  #JE todo use cached map
  def self.id_from_name(name)
    Country.where(name: name).pluck(:id).first
  end


end
