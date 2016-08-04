# == Schema Information
#
# Table name: custom_field_sets
#
#  created_at    :datetime         not null
#  division_id   :integer
#  id            :integer          not null, primary key
#  internal_name :string
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_custom_field_sets_on_division_id  (division_id)
#
# Foreign Keys
#
#  fk_rails_a3c049608b  (division_id => divisions.id)
#

class CustomFieldSet < ActiveRecord::Base
  include Translatable

  belongs_to :division

  has_many :custom_fields, -> { order(:position) }

  # define accessor like convenience methods for the fields stored in the Translations table
  attr_translatable :label

  def name
    label
  end

  def children
    custom_fields.where(parent: nil)
  end

  def child_groups
    children.select(&:group?)
  end

  def depth
    -1
  end

  # Builds and memoizes a hash of the form:
  # {
  #   q1 => {
  #     q1_1 => {},
  #     q1_2 => {}
  #     q1_3 => {
  #       q1_1_1 => {},
  #       q1_1_2 => {}
  #     }
  #   },
  #   q2 => {
  #     q2_1 => {},
  #     q2_2 => {}
  #   },
  #   q3 => {},
  #   q4 => {}
  # }
  # i.e. at each level, the tree elements are represented by hash keys and the children of each
  # element are the hash values.
  # Requires only N+1 database queries where N is the number of top level CustomFields.
  # Uses the closure_tree method of the same name.
  def hash_tree
    children.map { |c| [c, c.hash_tree[c]] }.to_h
  end

  # Builds and memoizes a hash mapping CustomFields to their children for all CustomFields in this set.
  # Requires no further database calls beyond those needed for `hash_tree`.
  # Uses the hash to return the children of the given parent.
  def children_for_parent(parent)
    if @children_by_parent.nil?
      @children_by_parent = {}
      build_parent_child_hash_for(hash_tree)
    end
    @children_by_parent[parent]
  end

  def depth_first_fields
    list = []
    counter = 0
    custom_fields.where(parent: nil).each do |top_group|
      counter += 1
      top_group.transient_position = counter
      top_group.traverse_depth_first(list)
    end
    list
  end

  # returns a field by either its id or internal_name
  def field(field_identifier, required: true)
    if field_identifier.is_a?(CustomField)
      field = field_identifier
    elsif field_identifier.is_a?(Integer)
      field = custom_fields.find_by(id: field_identifier)
    else
      field = custom_fields.find_by(internal_name: field_identifier)
    end
    raise "CustomField not found: #{field_identifier} for set: #{internal_name}"  if required && !field
    field
  end


  # Resolve the custom field set matching given internal name defined at the closest ancestor level.
  # future: consider merging field sets at each level of the hierarchy. (not sure if this is useful or desirable)
  def self.resolve(internal_name, division: nil, model: nil, required: true)
    # for model types which are not owned by a division, assume there is only a single CustomFieldSet defined
    # need special handling for Division class to avoid infinite loop
    if model.class == Division || !model.respond_to?(:division)
      return CustomFieldSet.find_by(internal_name: internal_name)
    end

    division = model.division  if !division && model
    if division
      # puts "CustomFieldSet.resolve - using division param"
      candidate_division = division
    else
      # puts "CustomFieldSet.resolve - using Division.root default"
      candidate_division = Division.root
    end

    result = nil
    # todo: confirm if there is a clever way to leverage closure tree to handle this hierarchical resolve logic
    while candidate_division do
      result = CustomFieldSet.find_by(internal_name: internal_name, division: candidate_division)
      break  if result
      candidate_division = candidate_division.parent
    end

    raise "CustomFieldSet not found: #{internal_name} for division: #{division.try(:id)}"  if required && !result
    result
  end

  private

  # Recursive method to construct @children_by_parent.
  def build_parent_child_hash_for(tree)
    tree.each_pair do |field, subtree|
      # Need to associate this copy of self with each descendant or performance will be poor.
      field.custom_field_set = self
      @children_by_parent[field] = subtree.keys
      build_parent_child_hash_for(subtree)
    end
  end
end
