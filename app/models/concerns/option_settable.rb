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
#     loan_type_option_list - list of hashes(value:xx, label:xx) for use as form select options
#     loan_type_option_label(value) - resolve a given value
#     loan_type_option_values - list of valid values - may be used by test model factory defs
#   instance level:
#     loan_type_label - instance's resolved option label
#

module OptionSettable
  extend ActiveSupport::Concern

  module ClassMethods

    # future: support division specific versions of the option sets
    def option_set_for(attribute)
      fetch_option_set(attribute)
    end

    def fetch_option_set(attribute)
      OptionSet.fetch(self, attribute)
    end

    def attr_option_settable(*attr_names)
      attr_names.each do |attr_name|
        singleton_class.instance_eval do
          define_method("#{attr_name}_option_set") do
            option_set_for(attr_name)
          end

          define_method("#{attr_name}_option_list") do
            option_set_for(attr_name).translated_list
          end

          define_method("#{attr_name}_option_label") do |value|
            option_set_for(attr_name).translated_label_by_value(value)
          end

          define_method("#{attr_name}_option_values") do
            option_set_for(attr_name).values
          end
        end

        define_method("#{attr_name}_label") do
          value = self.send("#{attr_name}_value")
          self.class.option_set_for(attr_name).translated_label_by_value(value)
        end
      end
    end
  end
end
