class CustomFieldSerializer < ActiveModel::Serializer
  attributes :id, :name, :children, :parent_id, :fieldset, :descendants_count, :optional

  def initialize(*args, loan: nil, **options)
    @loan = loan
    super(*args, options)
  end

  def name
    object.label.to_s
  end

  # jqtree expects children in a `children` key
  def children
    if object.children.present?
      # Recursively apply this serializer to children
      object.children.map { |node| self.class.new(node, loan: @loan) }
    end
  end

  def fieldset
    object.custom_field_set.internal_name.sub('loan_', '')
  end

  def descendants_count
    object.descendants.count
  end

  def optional
    @loan && !object.required_for?(@loan)
  end
end
