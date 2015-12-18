module MediaModule
  def get_media(table_name, id, limit=1, images_only=false, order_by=nil)
    order_by ||= 'Priority IS NULL, Priority = 0, Priority, MediaPath'
    
    items = Media.where(ContextTable: table_name, ContextID: id)
    items = items.type('image') if images_only
    items = items.order(order_by).limit(limit)
    
    return items
  end
end
