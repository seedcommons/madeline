class AddMediaKindOptions < ActiveRecord::Migration
  def up
    media_kind = OptionSet.find_or_create_by(division: Division.root, model_type: Media.name,
      model_attribute: 'kind')
    media_kind.options.destroy_all
    media_kind.options.create(value: 'image', label_translations: {en: 'Image', es: 'Imagen'})
    media_kind.options.create(value: 'video', label_translations: {en: 'Video', es: 'Vídeo'})
    media_kind.options.create(value: 'document', label_translations: {en: 'Document', es: 'Documento'})
    media_kind.options.create(value: 'contract', label_translations: {en: 'Contract', es: 'Contrato'})
  end
end
