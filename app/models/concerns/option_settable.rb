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
#     loan_type_option_set - the option set object
#     loan_type_options - list of pairs([label, value]) for input to `options_for_select`
#     loan_type_option_label(value) - resolve a given value
#     loan_type_option_values - list of valid values - may be used by test model factory defs
#   instance level:
#     loan_type_label - instance's resolved option label
#

module OptionSettable
  extend ActiveSupport::Concern

  module ClassMethods
    def option_set_for(attribute)
      OptionSet.fetch(self, attribute)
    end

    def attr_option_settable(*attr_names)
      attr_names.each do |attr_name|
        singleton_class.instance_eval do
          define_method("#{attr_name}_option_set") do
            option_set_for(attr_name)
          end

          define_method("#{attr_name}_options") do
            option_set_for(attr_name).translated_list
          end

          define_method("#{attr_name}_option_label") do |value|
            option_set_for(attr_name).translated_label_by_value(value)
          end

          define_method("#{attr_name}_option_values") do
            option_set_for(attr_name).values
          end
        end

        define_method("#{attr_name}_option") do
          @option_for ||= {}
          @option_for[attr_name] ||=
            option_set_for(attr_name).option_by_value(send("#{attr_name}_value"))
        end

        define_method("#{attr_name}_label") do
          @option_label_for ||= {}
          @option_label_for[attr_name] ||=
            option_set_for(attr_name).translated_label_by_value(send("#{attr_name}_value"))
        end
      end
    end
  end

  # This version is an instance method and memoizes, unlike the class version.
  def option_set_for(attribute)
    @option_set_for ||= {}
    @option_set_for[attribute] ||=
      OptionSet.fetch(self.class, attribute)
  end
end
