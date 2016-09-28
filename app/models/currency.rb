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
  def format_amount(amount, tooltip: true)
    display_symbol = symbol.sub('$', ' $') # add space before $ (pretty)
    if tooltip
      display_symbol = %Q(<a href="#" onclick="return false" data-toggle="tooltip" class="currency_symbol" title="#{plural_name}">#{display_symbol}</a> ).html_safe
    end
    return number_to_currency(amount, unit: display_symbol)
  end

  def division
    Division.root # for permissions purposes, assume currency model belongs to root division
  end

  private

  def plural_name
    # I18n.t()
    "#{name}s"
  end
end
