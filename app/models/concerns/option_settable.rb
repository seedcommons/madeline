#
# provides the ability to define and resolve sets of option values mapped to translatable labels for specific attributes
# of the including model
#
# including class should call 'attr_option_settable' with a list option attribute name prefixes
#   i.e.: attr_option_settable :status, :loan_type, :project_type, :public_level
#
# this assumes integer columns exist in the form of loan_type_option_id, etc.
# and that the corresponding OptionSet/Option db records exist.  (see seeds.db for examples)
#
# will define the attribute name prefixed methods in the following format:
#   class level:
#     loan_type_option_set - the raw option set
#     loan_type_option_list(language_code=nil) - list of hashes(value:xx, label:xx) for use as form select options
#     loan_type_option_label(value, language_code=nil) - resolve a given value
#     loan_type_option_values - list of valid values - may be used by test model factory defs
#   instance level:
#     loan_type_option_label(language_code=nil) - instance's resolved option label
#

module OptionSettable
  extend ActiveSupport::Concern

  included do
    # logger.debug("OptionSettable - included - #{self.name}")
  end

  module ClassMethods

    # future: support division specific versions of the option sets
    def option_set_for(attribute)
      fetch_option_set(attribute)
    end


    def fetch_option_set(attribute)
      OptionSet.fetch(self, attribute)
    end

    def resolve_option_label(model, attribute_name, language_code = nil)
      value = model.send("#{attribute_name}_option_id".to_sym)
      option_set = option_set_for(attribute_name)
      option_set.translated_label(value, language_code)
    end


    def attr_option_settable(*attr_names)
      attr_names.each do |attr_name|

        singleton_class.instance_eval do

          define_method("#{attr_name}_option_set") do
            option_set_for(attr_name)
          end

          define_method("#{attr_name}_option_list") do |language_code = nil|
            option_set_for(attr_name).translated_list(language_code)
          end

          define_method("#{attr_name}_option_label") do |value, language_code = nil|
            option_set_for(attr_name).translated_label(value, language_code)
          end

          define_method("#{attr_name}_option_values") do
            option_set_for(attr_name).values
          end

        end

        define_method("#{attr_name}_option_label") do |language_code = nil|
          value = self.send("#{attr_name}_option_id")
          # logger.info("option value: #{value}")
          self.class.option_set_for(attr_name).translated_label(value, language_code)
        end

        #UNUSED
        # ::AdHocCacheManager.add_hook("option_settable-#{self.name}") do
        #   Rails.logger.info("inside option_settable hook - #{self.name}")
        #   self.clear_cached_option_sets
        # end

      end
    end

  end

  def option_label(attribute_name, language_code = nil)
    self.class.resolve_option_label(self, attribute_name, language_code)
  end


end


#UNUSED
# future: make this cacheabale
#
# Note, conceptually this data is static configuration data persisted to the database,
# so fairly agressive caching is appropriate.
#
# def option_set_for(attribute)
#   option_sets[attribute.to_sym]
#   fetch_option_set(attribute)
# end
#
# def clear_cached_option_sets
#   logger.info("inside clear_cached_option_sets - class: #{self.name}")
#   @@option_sets = nil
# end
#
# def option_sets
#   @@option_sets ||= Hash.new do |h, attribute|
#     logger.info("options_sets - generating value for: #{attribute}")
#     h[attribute.to_sym] = fetch_option_set(attribute)
#   end
# end
