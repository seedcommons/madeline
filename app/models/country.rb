# == Schema Information
#
# Table name: countries
#
#  id                  :integer          not null, primary key
#  created_at          :datetime         not null
#  default_currency_id :integer
#  default_language_id :integer
#  iso_code            :string(2)
#  language_id         :integer
#  name                :string
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_countries_on_language_id  (language_id)
#
# Foreign Keys
#
#  fk_rails_12b1744656  (default_language_id => languages.id)
#  fk_rails_6f479b409c  (language_id => languages.id)
#  fk_rails_cc2d004fbb  (default_currency_id => currencies.id)
#

class Country < ActiveRecord::Base
  belongs_to :default_language, class_name: 'Language'
  belongs_to :default_currency, class_name: 'Currency'

  #JE todo use cached map
  def self.id_from_name(name)
    Country.where(name: name).pluck(:id).first
  end


end
