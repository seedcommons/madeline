class Admin::Raw::CustomValueSetsController < BaseCrudController


  protected

  # fields needed for initial model creation
  def create_attrs
    [:custom_value_set_linkable_type, :custom_value_set_linkable_id, :custom_field_set_id, :linkable_attribute ]
  end

  def update_attrs
    [:custom_value_set_linkable_type, :custom_value_set_linkable_id, :custom_field_set_id, :linkable_attribute,
     :custom_data]
  end


end
