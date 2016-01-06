module MediaAttachable
  extend ActiveSupport::Concern

  included do
    has_many :media, as: :media_attachable
  end

  def get_media(limit: 1, images_only: false, sort_order: nil)
    sort_order ||= 'sort_order IS NULL, sort_order = 0, sort_order, item'
    media_items = media.order(sort_order).limit(limit)
    media_items = media_items.images_only if images_only
    media_items
  end
end
