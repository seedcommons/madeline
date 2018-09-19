module TranslationsHelper
  def html_format(text)
    text.gsub("\n", '<br>').html_safe
  end

  def render_translation(translation)
    if translation
      if translation.locale == I18n.locale.to_s
        content_tag(:span, html_format(translation.text), class: "translation home_language")
      else
        content_tag(:span, html_format(translation.text), class: "translation foreign_language",
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

  def translate_boolean(bool)
    t(bool ? "reply_yes" : "reply_no")
  end
end

module SimpleForm
  class FormBuilder
    include TranslationsHelper

    def translatable_inputs(&block)
      object_name = object.model_name.singular
      out = %Q{
        <div class="languages" data-content-translatable="#{object_name}">
          <input class="deleted-locales" name="#{object_name}[deleted_locales][]" type="hidden" />
      }.html_safe
      # TODO: Fix this to only show defined locales again
      I18n.available_locales.each do |l|
        # .row is added to language-block to address styling problems
        out += %Q{
          <div class="language-block row" data-locale="#{l}">
          <fieldset>
            <legend>#{name_for_locale(l)}</legend>
        }.html_safe

        out += template.capture { yield l }

        out += "</fieldset></div>".html_safe
      end

      out += "</div>".html_safe

      out
    end
  end
end
