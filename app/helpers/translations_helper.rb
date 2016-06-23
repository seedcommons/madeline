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

  def translate_boolean(bool)
    t(bool ? "reply_yes" : "reply_no")
  end
end

module SimpleForm
  class FormBuilder
    include TranslationsHelper

    def translatable_inputs(&block)
      out = %Q{
        <div class="languages">
          <input class="deleted-locales" name="#{object.model_name.singular}[deleted_locales][]" type="hidden" />
      }.html_safe
      object.used_locales_or_current_locale.each do |l|
        out += %Q{
          <div class="language-block" data-locale="#{l}">
            <a class="remove-language" href="#">#{I18n.t('common.remove')}</a>
        }.html_safe
        out += input :"locale_#{l}", label: false,
          collection: locale_options,
          input_html: {class: 'locale'}, include_blank: false

        out += template.capture { yield l }

        out += "</div>".html_safe
      end
      out += %Q{
          <a class="add-language" href="#">#{I18n.t('common.add_language')}</a>
        </div>
      }.html_safe
      out
    end
  end
end
