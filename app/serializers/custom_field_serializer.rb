class CustomFieldSerializer < ActiveModel::Serializer
  attributes :id, :name, :children, :parent_id, :fieldset, :descendants_count

  def initialize(*args, loan: nil)
    @loan = loan
    super(*args)
  end

  def name
    object.label.to_s
  end

  # jqtree expects children in a `children` key
  def children
    if object.children.present?
      # Recursively apply this serializer to children
      object.children.sort_by_required(@loan).map { |node| self.class.new(node) }
    end
  end

  def fieldset
    object.custom_field_set.internal_name.sub('loan_', '')
  end

  def descendants_count
    object.descendants.count
  end
end
