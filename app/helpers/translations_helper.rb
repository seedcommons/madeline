module TranslationsHelper
  def html_format(text)
    text.gsub("\n", '<br>').html_safe
  end

  def render_translation(translation)
    if translation
      if translation.language.code == I18n.language_code
        content_tag(:span, html_format(translation.content), class: "translation home_language")
      else
        content_tag(:span, html_format(translation.content), class: "translation foreign_language",
          'data-content' => I18n.t(:not_yet_translated))
      end
    end
  end

  def name_for_locale(locale)
    I18n.t("locale_name.#{locale}", locale: locale)
  end

  # Returns a list of locale and name pairs suitable for input to `options_for_select`
  def locale_options
    I18n.available_locales.map{ |locale| [name_for_locale(locale), locale] }
  end
end
