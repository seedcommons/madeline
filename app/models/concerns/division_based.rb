module DivisionBased
  extend ActiveSupport::Concern

  included do
    scope :in_division, -> (division) { where(division: division.self_and_descendants) }

    def self.filter_by_division(division)
      # in_division(division).map { |i| [i.name, i.id] }
      in_division(division).pluck(:name)
    end
  end
end
