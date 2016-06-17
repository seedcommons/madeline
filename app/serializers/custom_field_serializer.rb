class CustomFieldSerializer < ActiveModel::Serializer
  attributes :id, :name, :children, :parent_id, :custom_field_set_id, :descendants_count

  def name
    object.label.to_s
  end

  # jqtree expects children in a `children` key
  def children
    if object.children.present?
      # Recursively apply this serializer to children
      object.children.map { |node| self.class.new(node) }
    end
  end

  def descendants_count
    object.descendants.count
  end
end
