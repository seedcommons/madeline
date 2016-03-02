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
    #   get_translations('foo')
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

  def get_translation(attribute, locale: I18n.locale, exact_match: false)
    # important to filter against the association held in memory instead of performing a db lookup
    # in order to redisplay potentially transient values
    result = translations.find{|t|
      t.translatable_attribute.to_sym == attribute.to_sym && t.locale.to_sym == locale.to_sym
    }
    unless result || exact_match
      # fall back to first translations of any locale if desired locale not present
      # (except when fetching in order to perform update)
      result = translations.find{|t|
        t.translatable_attribute.to_sym == attribute.to_sym
      }
    end
    result
  end

  def get_translations(attribute)
    translations.where(translatable_attribute: attribute)
  end

  def used_locales
    translations.pluck(:locale).uniq.map {|l| l.to_sym}
  end

  def delete_translation(attribute, locale)
    translation = get_translation(attribute, locale:locale, exact_match: true)
    translation.delete
  end

  def set_translation(attribute, text, locale: I18n.locale, old_locale: nil)
    translation = get_translation(attribute, locale: old_locale || locale, exact_match: true)
    if translation
      translation.assign_attributes(text: text, locale: locale)
    else
      translations.build(translatable_attribute: attribute, locale: locale, text: text)
    end
    text
  end

  def set_translations(attribute, translations = {})
    translations.each do |locale, text|
      set_translation(attribute, text, locale: locale)
    end
  end

  # returns the element from the parent objects association list for the given object's id
  # necessary to get autosave behavior to work as desired
  # def associated_translation(translation)
  #   if translation
  #     translations.find{|t| t.id == translation.id}
  #   else
  #     translation
  #   end
  # end

  #
  # define a easy way to fetch a named attribute for a specific locale
  #
  # <attribute>_<locale> is equivalent to translations.where(translatable_attribute: attribute, locale: locale).first
  #

  def method_missing(method_sym, *arguments, &block)
    # the first argument is a Symbol, so you need to_s it if you want to pattern match
    #fixme: make this dynamic method pattern more unique
    if method_sym.to_s =~ /^(.*)_(.*)$/
      if $2 != "translations" && respond_to?("#{$1}_translations")
        translation = translations.where(translatable_attribute: $1, locale: $2).first
        if translation
          return translation.text
        else
          return ''
        end
      end
    end
    super
  end

  def respond_to?(method_sym, include_private = false)
    if method_sym.to_s =~ /^(.*)_(.*)$/
      # translation = translations.where(translatable_attribute: $1, locale: $2).first
      # return translation.present?
      if $2 != "translations" && respond_to?("#{$1}_translations")
        return true
      end
    end
    super
  end

end
