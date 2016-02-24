# == Schema Information
#
# Table name: countries
#
#  created_at          :datetime         not null
#  default_currency_id :integer
#  id                  :integer          not null, primary key
#  iso_code            :string(2)
#  name                :string
#  updated_at          :datetime         not null
#
# Foreign Keys
#
#  fk_rails_cc2d004fbb  (default_currency_id => currencies.id)
#

class Country < ActiveRecord::Base
  belongs_to :default_currency, class_name: 'Currency'

  #JE todo use cached map
  def self.id_from_name(name)
    Country.where(name: name).pluck(:id).first
  end


end
