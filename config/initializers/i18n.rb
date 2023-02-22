# note, 'es' is needed here to support leveraging the I18n system to translate our locale_name for the
# language selection drop-down
Rails.application.config.i18n.available_locales = %w(en es)
RouteTranslator.config do |config|
  config.disable_fallback = true
  config.force_locale = true
  config.available_locales = %w(en es)
  config.hide_locale = true
end
