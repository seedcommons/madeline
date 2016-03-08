module Translatable
  extend ActiveSupport::Concern

  included do
    has_many :translations, as: :translatable, autosave: true
    accepts_nested_attributes_for :translations
  end

  module ClassMethods

    #
    # define convenience methods for assigning and fetching the named attribute
    #
    # equivalent to:
    #
    # def foo
    #   get_translation('foo')
    # end
    #
    # def foo=(text)
    #   set_translation('foo', text)
    # end
    #
    # def set_foo(text, locale)
    #   set_translation('foo', text, locale)
    # end
    #
    # def foo_translations
    #   get_all_translations('foo')
    # end
    #
    # def foo_translations=(translations)
    #   set_translations('foo', translations)
    # end

    def attr_translatable(*attributes)
      attributes.each do |attribute|
        define_method(attribute) { get_translation(attribute) }
        define_method("#{attribute}=") { |text| set_translation(attribute, text) }
        define_method("set_#{attribute}") do |text, locale: I18n.locale|
          set_translation(attribute, text, locale: locale)
        end
        define_method("#{attribute}_translations") { get_translations(attribute) }
        define_method("#{attribute}_translations=") { |translations| set_translations(attribute, translations) }
        alias_method "set_#{attribute}_translations", "#{attribute}_translations="
      end
    end
  end

  def get_translation(attribute)
    translation = translations.find_by(translatable_attribute: attribute, locale: I18n.locale)
    translation = get_translations(attribute).first  unless translation
    return associated_translation(translation) if translation
    nil
  end

  def get_translations(attribute)
    translations.where(translatable_attribute: attribute)
  end

  def set_translation(attribute, text, locale: I18n.locale)
    translation = get_translation(attribute)
    if translation
      translation.assign_attributes(text: text)
    else
      translation = translations.build(translatable_attribute: attribute, locale: locale, text: text)
    end
    text
  end

  def set_translations(attribute, translations = {})
    translations.each do |locale, text|
      set_translation(attribute, text, locale: locale)
    end
  end

  # returns the element from the parent objects assocation list for the given object's id
  # necessary to get autosave behavior to work as desired
  def associated_translation(translation)
    if translation
      translations.find{|t| t.id == translation.id}
    else
      translation
    end
  end
end
