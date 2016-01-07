# == Schema Information
#
# Table name: countries
#
#  id                  :integer          not null, primary key
#  iso_code            :string(2)
#  default_currency_id :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  name                :string
#  default_language_id :integer
#  language_id         :integer
#
# Indexes
#
#  index_countries_on_language_id  (language_id)
#

class Country < ActiveRecord::Base
  belongs_to :default_language, class_name: 'Language'
  belongs_to :default_currency, class_name: 'Currency'

  #JE todo use cached map
  def self.id_from_name(name)
    Country.where(name: name).pluck(:id).first
  end


end
