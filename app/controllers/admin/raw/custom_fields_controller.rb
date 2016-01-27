class Admin::Raw::CustomFieldsController < BaseCrudController


  protected

  # fields needed for initial model creation
  def create_attrs
    [:custom_field_set_id, :internal_name]
  end

  def update_attrs
    [:custom_field_set_id, :internal_name, :label, :data_type, :position, :parent_id]
  end


end
