module DivisionBased
  extend ActiveSupport::Concern

  included do
    def self.in_division(division)
      division ? where(division_id: division.self_and_descendant_ids) : all
    end

    def self.in_ancestor_or_descendant_division(division)
      where(division_id: division.self_and_descendant_ids + division.ancestor_ids)
    end

    # For wicegrid custom filters
    def self.filter_in_division(division, order: :name)
      in_division(division).order(order).map { |i| [i.name, i.id] }
    end
  end
end
