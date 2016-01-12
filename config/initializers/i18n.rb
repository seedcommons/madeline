Rails.application.config.i18n.available_locales = %w(en es-AR)
RouteTranslator.config do |config|
  config.disable_fallback = true
end
