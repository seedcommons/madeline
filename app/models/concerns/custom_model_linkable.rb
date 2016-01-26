#
# Manages relations to dynamic model instance with a schema specific to the assigned
# association, and potentially customizable per division.
# Used to link a loan to its sets of questionnaire response data
#
# Three class level association definition methods are provided:
#   has_one_custom - where association is defined by a back reference from the CustomModel and up to one instance is expected
#   has_many_custom - where association is defined by a back reference from the CustomModel and multiple instances are supported
#   belongs_to_custom - where association is defined by an xxx_id column on referencing class, supports references to objects not 'owned' by current object
#


module CustomModelLinkable
  extend ActiveSupport::Concern

  included do
    has_many :custom_models, as: :custom_model_linkable
  end



  module ClassMethods

    def belongs_to_custom(attr_name, field_set: nil, foreign_key: nil)
      logger.debug "belongs_to_custom: #{attr_name}, field_set: #{field_set}, foreign_key: #{foreign_key}"
      define_method(attr_name) do |autocreate: false, owner: nil|
        fetch_belongs_to_custom(attr_name, field_set_name: field_set, foreign_key_name: foreign_key, autocreate: autocreate, owner: owner)
      end
      define_method("create_#{attr_name}") do |owner: nil|
        create_belongs_to_custom(attr_name, field_set_name: field_set, foreign_key_name: foreign_key, owner: owner)
      end
    end

    def has_one_custom(attr_name, field_set: nil)
      logger.debug "has_one_custom: #{attr_name}, field_set: #{field_set}"
      define_method(attr_name) do |autocreate: false|
        fetch_has_one_custom(attr_name, field_set_name: field_set, autocreate: autocreate)
      end
      define_method("create_#{attr_name}") { create_has_custom(attr_name, field_set_name: field_set) }
    end

    def has_many_custom(attr_name, field_set: nil)
      logger.debug "has_one_custom: #{attr_name}, field_set: #{field_set}"
      getter_name = attr_name.to_s.pluralize
      define_method(getter_name) do
        fetch_has_many_custom(attr_name)
      end
      define_method("create_#{attr_name}") { create_has_custom(attr_name, field_set_name: field_set) }
    end


  end


  # Find or create the value set instance associated with given field set name for this model instance
  def fetch_has_one_custom(attr_name, field_set_name: nil, autocreate: false)

    result = custom_models.where({ custom_model_linkable: self, linkable_attribute: attr_name }).first
    if autocreate && !result
      result = create_has_custom(attr_name, field_set_name: field_set_name)
    end
    result
  end


  def fetch_has_many_custom(attr_name)
    custom_models.where(linkable_attribute: attr_name)
  end


  def create_has_custom(attr_name, field_set_name: nil)
    field_set_name ||= attr_name
    field_set = CustomFieldSet.resolve(field_set_name, model: self)
    custom_models.create(custom_field_set: field_set, linkable_attribute: attr_name)
  end

  # Note, the 'owner' param supports assigning a reference to an object which is 'owned' by a different object.
  # This is needed for loan questionnairs which are linked from a Loan, but owned by an Organization
  def fetch_belongs_to_custom(attr_name, field_set_name: nil, foreign_key_name: nil, owner: nil, autocreate: false)
    foreign_key_name ||= "#{attr_name}_id"
    existing_id = get_attribute(foreign_key_name)
    if existing_id
      result = CustomModel.find(existing_id)
    else
      if autocreate
        result = create_belongs_to_custom(attr_name, field_set_name: field_set_name, foreign_key_name: foreign_key_name, owner: owner)
      else
        result = nil
      end
    end
    result
  end


  def create_belongs_to_custom(attr_name, field_set_name: nil, foreign_key_name: nil, owner: nil)
    field_set_name ||= attr_name
    foreign_key_name ||= "#{attr_name}_id"
    owner ||= self
    field_set = CustomFieldSet.resolve(field_set_name, model: owner)
    result = owner.custom_models.create({ custom_field_set: field_set, linkable_attribute: attr_name })
    update_attribute(foreign_key_name, result.id)
    result
  end


  # handles both core db columns and custom field attributes
  def get_attribute(attr_name)
    if respond_to?(attr_name)
      send(attr_name)
    # custom field attributes now handled via method_missing hook
    # elsif respond_to?('custom_field?') && custom_field?(attr_name)
    #   custom_value(attr_name)
    else
      raise "#{self.name} - unable to get attribute: #{attr_name}"
    end
  end

  # handles both core db columns and custom field attributes
  def update_attribute(attr_name, value)
    if self.class.column_names.include?(attr_name)
      update(attr_name => value)
    # custom field attributes now handled via method_missing hook
    # elsif respond_to?('custom_field?') && custom_field?(attr_name)
    #   update_custom_value(attr_name, value)
    else
      raise "#{self.name} - unable to update attribute: #{attr_name}"
    end
  end

end


