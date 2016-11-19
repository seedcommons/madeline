# == Schema Information
#
# Table name: currencies
#
#  id           :integer          not null, primary key
#  code         :string
#  symbol       :string
#  short_symbol :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  name         :string
#

class Currency < ActiveRecord::Base
  def division
    Division.root # for permissions purposes, assume currency model belongs to root division
  end

  private

  def plural_name
    # This should obviously be refactored someday. Ideally the currency's name field would
    # be converted to be translatable. Currently the name is stored only in English.
    # As of 9/2016 this is only used in the public front end (which is used in Spanish as well!).
    "#{name}s"
  end
end
