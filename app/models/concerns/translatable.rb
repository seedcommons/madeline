module Translatable
  extend ActiveSupport::Concern

  included do
    has_many :translations, as: :translatable
  end

  module ClassMethods
    #
    # define convenience methods for assigning and fetching the named attribute
    #
    # equivalent to:
    #
    # def foo
    #   get_translation('foo', I18n.language_code)
    # end
    #
    # def foo=(text)
    #   set_translation('foo', text, I18n.language_code)
    # end
    #
    # def get_foo(language_code)
    #   get_translation('foo', language_code)
    # end
    #
    # def set_foo(text, language_code)
    #   set_translation('foo', text, language_code)
    # end
    #
    # def foo_list
    #   translations_list('foo')
    # end
    #
    # def foo_map
    #  translations_map('foo')
    # end
    def attr_translatable(*attr_names)
      # logger.info "attr_names: #{attr_names.inspect}"
      attr_names.each do |attr_name|
        define_method("get_#{attr_name}") { |language_code = nil| get_translation(attr_name, language_code) }
        define_method("set_#{attr_name}") { |text, language_code = nil| set_translation(attr_name, text, language_code) }
        define_method("set_#{attr_name}_list") { |list| set_translation_list(attr_name, list) }
        define_method("get_#{attr_name}") do |language: nil|
          get_translation(attr_name, language: language)
        end
        define_method("set_#{attr_name}") do |text, language: nil|
          set_translation(attr_name, text, language: language)
        end

        define_method(attr_name) { resolve_translation(attr_name, language: nil) }
        define_method("#{attr_name}=") { |text| set_translation(attr_name, text, language: nil) }

        define_method("#{attr_name}_list") { translations_list(attr_name) }
        define_method("#{attr_name}_map") { translations_map(attr_name) }
      end
    end
  end

  def get_translation(attribute_name, language: nil)
    language ||= Language.for_locale
    t = get_translation_obj(attribute_name, language_code)
    t.try(:text)
  end

  def resolve_translation(attribute_name, language: nil)
    language ||= Language.for_locale

    # Get translation for current locale
    translation = get_translation_obj(attribute_name, language: language)
    return translation.try(:text) if translation.present?

    # Get translation for default locale
    if I18n.locale != I18n.default_locale
      translation = get_translation_obj(attribute_name, language: Language.for_locale(I18n.default_locale))
      return translation.try(:text) if translation.present?
    end

    # Get first available translation
    translation = translations.where(translatable_attribute: attribute_name).first
  end

  def set_translation(attribute_name, text, language: nil)
    language ||= Language.for_locale

    translation = get_translation_obj(attribute_name, language: language)
    if translation
      translation.text = text
      translation.save
    else
      translations << Translation.create(
        translatable_attribute: attribute_name,
        language: language,
        text: text
      )
    end
    text
  end

  # batch assignemnt of a set of translations
  # list: list of |language_code, text|  (note a map can also be passed as it behaves the same when iterated over with each)
  def set_translation_list(attribute_name, list)
    list.each do |language_code, text|
      set_translation(attribute_name, text, language_code)
    end
  end

  # batch assignemnt of a set of translations
  # map of language_code => text
  def set_translation_map(attribute_name, list)
    list.each do |language_code, text|
      set_translation(attribute_name, text, language_code)
    end

  end

  private

  def get_translation_obj(attribute_name, language: nil)
    language ||= Language.for_locale
    result = translations.find_by(translatable_attribute: attribute_name, language: language)
  end

  # returns all translations as a map keyed by language_code
  def translations_map(attribute_name)
    hash = {}
    translations.where({translatable_attribute: attribute_name}).each{ |t| hash[t.language.code] = t.text }
    hash
  end

  # returns all translations as an ordered list of [code,text]
  def translations_list(attribute_name)
    translations_map(attribute_name).sort_by{ |code, text| code }
  end
end
