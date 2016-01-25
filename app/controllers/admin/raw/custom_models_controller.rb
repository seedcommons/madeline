class Admin::Raw::CustomModelsController < BaseCrudController


  protected

  # fields needed for initial model creation
  def create_attrs
    [:custom_model_linkable_type, :custom_model_linkable_id, :custom_field_set_id, :linkable_attribute ]
  end

  def update_attrs
    [:custom_model_linkable_type, :custom_model_linkable_id, :custom_field_set_id, :linkable_attribute,
     :custom_data]
  end


end
