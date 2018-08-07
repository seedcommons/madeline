module CurrencyHelper
  def format_currency(amount, currency, tooltip: true)
    currency_name = I18n.t("common.currency.#{currency.try(:locale_name)}")
    display_symbol = currency ? "#{currency.country_code} #{currency.short_symbol}" : ''

    if tooltip
      display_symbol = %Q(<a href="#" onclick="return false" data-toggle="tooltip"
        class="currency_symbol" title="#{currency_name}">#{display_symbol}</a>).html_safe
    end

    # since we want to display all amounts with the symbols in front and dot notation
    # we're adding locale: :en to set it to the English format by default
    number_to_currency(amount, unit: display_symbol, negative_format: "(%u%n)", locale: :en)
  end
end
