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
  include ActionView::Helpers::NumberHelper

  def division
    Division.root # for permissions purposes, assume currency model belongs to root division
  end

  def format_amount(amount, tooltip: true)
    display_symbol = symbol.sub('$', ' $') # add space before $ (pretty)
    if tooltip
      display_symbol = %Q(<a href="#" onclick="return false" data-toggle="tooltip"
        class="currency_symbol" title="#{plural_name}">#{display_symbol}</a> ).html_safe
    end
    return number_to_currency(amount, unit: display_symbol)
  end

  private

  def plural_name
    # This should obviously be refactored someday. Ideally the currency's name field would
    # be converted to be translatable. Currently the name is stored only in English.
    # As of now this is only used in the public front end (which is used in Spanish as well!).
    "#{name}s"
  end
end
