module DivisionBased
  extend ActiveSupport::Concern

  included do
    scope :in_division, -> (division) { where(division: division.self_and_descendants) }

    # For wicegrid custom filters
    def self.filter_by_division(division, order: :name)
      in_division(division).order(order).map { |i| [i.name, i.id] }
    end
  end
end
