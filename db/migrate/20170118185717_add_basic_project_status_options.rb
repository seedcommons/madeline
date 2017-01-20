class AddBasicProjectStatusOptions < ActiveRecord::Migration
  def change
    basic_project_status = OptionSet.find_or_create_by(division: Division.root, model_type: BasicProject.name,
      model_attribute: 'status')
    basic_project_status.options.destroy_all
    basic_project_status.options.create(value: 'active',
      label_translations: {en: 'Active', es: 'Activo'})
    basic_project_status.options.create(value: 'completed',
      label_translations: {en: 'Completed', es: 'Completo'})
    basic_project_status.options.create(value: 'changed',
      label_translations: {en: 'Changed', es: 'Cambiado'})
    basic_project_status.options.create(value: 'possible',
      label_translations: {en: 'Possible', es: 'Posible'})
  end
end
