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
    # It is important to filter against the association held in memory (instead of fetching the data from the DB)
    # in order to redisplay potentially transient values when there is a validation error and a form needs to be
    # displayed with values not yet # saved to the DB.
    result = translations.find do |t|
      t.translatable_attribute.to_sym == attribute.to_sym && t.locale.to_sym == locale.to_sym
    end
    unless result || exact_match
      # When we are just displaying a translatable value, we'll show the user's default locale,
      # but if not available, then we'll show the first available one. In this case `exact_match:false` is passed in.
      # When editing a form, we only want resolve the exact locale provided and `exact_match:true` is passed in.
      result = translations.find do |t|
        t.translatable_attribute.to_sym == attribute.to_sym
      end
    end
    result
  end

  def get_translations(attribute)
    translations.where(translatable_attribute: attribute)
  end

  # todo: consider duck typing here, but would probably want to first introduced our own base model class
  def used_locales
    result = []
    if respond_to?(:division)
      result = self.division.try(:resolve_default_locales)
    end
    result += translations.pluck(:locale)

    # need to ignore any existing locales in UI if they don't currently correspond to a permitted locale
    result.map(&:to_sym) & self.permitted_locales
  end

  # Beware, this is distinct from I18n.available_locales to flatten out the region specific locales
  # for the purpose of the translatable fields.
  # If we really want to support es-AR, etc in the translatable system, we need to tweak the migration
  # and also think through all of the other implications
  def permitted_locales
    [:en, :es, :fr]   # todo: determine full list here
    # Note, this list currently depends on being included in the I18n.available_locales list
    # because we're leveraging the I18n system to translate our locale_name for the
    # language selection drop-down.
    # If we're okay with just using a simple map instead, then we could avoid that dependency.
  end

  def unused_locales
    permitted_locales - used_locales
  end

  def delete_translation(attribute, locale)
    translation = get_translation(attribute, locale: locale, exact_match: true)
    translation.delete if translation
  end

  # if old_locale is provided and different from locale, then the language for an existing set of translations
  # was changed from one language to another within the edit UI, and we need to match against that existing record
  # when fetching for the update
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

  # todo: consider a different location for this helper
  # Returns a hash of the translated terms in all permitted locales for this translatable
  def translate(*terms)
    permitted_locales.each_with_object({}) do |l, res|
      res[l] = terms.each_with_object({}) do |term, res|
        res[term] = I18n.t(term, locale: l)
      end
    end
  end

  # clones all translations associated with current instance into target translatable instance as transient values
  def clone_translations(destination)
    translations.each do |translation|
      destination.translations.build(
          translatable_attribute: translation.translatable_attribute,
          locale: translation.locale,
          text: translation.text
      )
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
  # Form helpers
  #

  #
  # define a easy way to fetch a named attribute for a specific locale
  #   <attribute>_<locale> is equivalent to translations.where(translatable_attribute: attribute, locale: locale).first
  #
  # support for detecting a changed locale for an existing translation
  #   locale_<locale> returns the locale component of the method name
  #

  def method_missing(method_sym, *arguments, &block)
    # todo: consider make this dynamic method pattern more unique
    if method_sym.to_s =~ /\A(.*)_(.*)\z/
      if $2 != "translations" && respond_to?("#{$1}_translations")
        translation = get_translation($1, locale: $2, exact_match: true)
        return translation.try(:text)
      end
    end
    if method_sym.to_s =~ /\Alocale_(.*)\z/
      # note, this assumes that invalid locales are already filtered out before reaching UI.
      if permitted_locales.include? $1.to_sym
        return $1
      end
    end
    super
  end

  def respond_to?(method_sym, include_private = false)
    if method_sym.to_s =~ /\A(.*)_(.*)\z/
      if $2 != "translations" && respond_to?("#{$1}_translations")
        return true
      end
    end
    if method_sym.to_s =~ /\Alocale_(.*)\z/
      if permitted_locales.include? $1.to_sym
        return permitted_locales.include? $1.to_sym
      end
    end
    super
  end

end
