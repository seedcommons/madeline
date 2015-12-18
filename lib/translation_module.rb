module TranslationModule
  # add translation method to all models that include this module
  extend ActiveSupport::Concern
  included do
    # may return nil
    def translation(column_name, language_code = I18n.language_code)
      get_translation(self.class.table_name.camelize, self.id, column_name, language_code)
    end
  end

  def get_translation(table_name, id, column_name, language_code)
    translations = Translation.joins(:language).where(
      :RemoteTable => table_name,
      :RemoteColumnName => column_name,
      :RemoteID => id
    )
    return translations.where('Languages.Code' => language_code).try(:first) ||
           translations.order('Languages.Priority').try(:first)
  end

  include ActionView::Helpers::NumberHelper
  def currency_format(amount, currency, tooltip=true)
    symbol = currency.symbol
    symbol = symbol.sub('$', ' $') # add space before $ (pretty)
    if tooltip
      symbol = %Q(<a href="#" onclick="return false" data-toggle="tooltip" class="currency_symbol" title="#{currency.name}s">#{symbol}</a> ).html_safe
    end
    return number_to_currency(amount, :unit => symbol)
  end
end

module I18n
  # Convert locale code to language code used by database
  def self.language_code
    locale.to_s[0,2].upcase
  end
end
