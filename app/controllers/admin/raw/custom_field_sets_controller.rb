class Admin::Raw::CustomFieldSetsController < BaseCrudController


  protected

  # fields needed for initial model creation
  def create_attrs
    [:division_id, :internal_name]
  end

  def update_attrs
    [:division_id, :internal_name, :label]
  end


end
