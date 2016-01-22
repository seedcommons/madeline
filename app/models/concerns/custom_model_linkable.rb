#
# Manages relations to dynamic model instance with a schema specific to the assigned
# association, and potentially customizable per division.
# Used to link a loan to its sets of questionnaire response data
#


module CustomModelLinkable
  extend ActiveSupport::Concern

  included do
    has_many :custom_models, as: :custom_model_linkable
  end



  module ClassMethods

    # define convenience methods to access associated CustomValueSet instances by a CustomFieldSet name
    def attr_custom_model_linkable(*custom_field_set_names)
      logger.info "custom_field_set_names: #{custom_field_set_names.inspect}"
      custom_field_set_names.each do |name|
        define_method(name) { |autocreate: true| custom_model(name, autocreate: autocreate) }
      end
    end
  end

  # find or create the value set instance associated with given field set name for this model instance
  def custom_model(field_set_name, autocreate: true)
    field_set = CustomFieldSet.resolve(field_set_name, model: self)

    method = autocreate ? :find_or_create_by : :find_by
    custom_models.send(method, {custom_model_linkable: self, custom_field_set: field_set})
  end



end


