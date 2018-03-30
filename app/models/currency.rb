# == Schema Information
#
# Table name: currencies
#
#  code         :string
#  country_code :string
#  created_at   :datetime         not null
#  id           :integer          not null, primary key
#  name         :string
#  short_symbol :string
#  symbol       :string
#  updated_at   :datetime         not null
#

class Currency < ActiveRecord::Base
  validates :name, uniqueness: { scope: [:code, :country_code, :short_symbol, :symbol] }
  
  def division
    Division.root # for permissions purposes, assume currency model belongs to root division
  end

  def plural_name
    # TODO: This should obviously be refactored someday. Ideally the currency's name field would
    # be converted to be translatable. Currently the name is stored only in English.
    "#{name}s"
  end
end
