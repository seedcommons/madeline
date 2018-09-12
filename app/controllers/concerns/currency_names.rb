module CurrencyNames
  extend ActiveSupport::Concern

  included { helper_method :currency_name }

  def currency_name(currency, count:)
    currency ? I18n.t("common.currency.#{currency.code}", count: count) : ''
  end
end
