module TranslationsHelper
  def html_format(text)
    text.gsub("\n", '<br>').html_safe
  end

  def render_translation(translation)
    if translation
      if translation.language.code == I18n.locale
        content_tag(:span, html_format(translation.text), class: "translation home_language")
      else
        content_tag(:span, html_format(translation.text), class: "translation foreign_language",
          'data-content' => I18n.t(:not_yet_translated))
      end
    end
  end

end
