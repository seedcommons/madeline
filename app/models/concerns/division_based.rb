module DivisionBased
  extend ActiveSupport::Concern

  included do
    scope :in_division, -> (division) { where(division: division.self_and_descendants) }

    def self.filter_by_division(division)
      in_division(division).order(:name).map { |i| [i.name, i.id] }
    end
  end
end
