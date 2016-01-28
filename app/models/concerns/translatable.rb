module Translatable
  extend ActiveSupport::Concern     ## consider using SuperModule

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

  #
    def attr_translatable(*attr_names)
      logger.info "attr_names: #{attr_names.inspect}"
      attr_names.each do |attr_name|
        define_method("get_#{attr_name}") { |language_code = nil| get_translation(attr_name, language_code) }
        define_method("set_#{attr_name}") { |text, language_code = nil| set_translation(attr_name, text, language_code) }
        define_method("set_#{attr_name}_list") { |list| set_translation_list(attr_name, list) }

        define_method(attr_name) { resolve_translation(attr_name, nil) }
        define_method("#{attr_name}=") { |text| set_translation(attr_name, text, nil) }

        define_method("#{attr_name}_list") { translations_list(attr_name) }
        define_method("#{attr_name}_map") { translations_map(attr_name) }
      end
    end
  end

  def get_translation(attribute_name, language_code = nil)
    t = get_translation_obj(attribute_name, language_code)
    t.try(:text)
  end

  def resolve_translation(attribute_name, language_code = nil)
    translation = get_translation_obj(attribute_name, language_code) ||
        translations.where({translatable_attribute: attribute_name}).first  # fallback to any avail translation, todo: better prioritization
    translation
  end

  def get_translation_obj(attribute_name, language_code = nil)
    language_id = Language.resolve_id(language_code)
    result = translations.where({translatable_attribute: attribute_name, language_id: language_id}).first
  end

  def set_translation(attribute_name, text, language_code = nil)
    t = get_translation_obj(attribute_name, language_code)
    if t
      t.text = text
      t.save
    else
      language_id = Language.resolve_id(language_code)
      translations.create(translatable_attribute: attribute_name, language_id: language_id, text: text)
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

  # returns all translations as a map keyed by language_code
  def translations_map(attribute_name)
    hash = {}
    translations.where({translatable_attribute: attribute_name}).each{|t| hash[t.language.code] = t.text}
    hash
  end

  # returns all translations as an ordered list of [code,text]
  def translations_list(attribute_name)
    #todo: propertly sort, once sort order is well defined
    translations.where({translatable_attribute: attribute_name}).map{ |t| {code: t.language.code, text: t.text} }
  end


end
