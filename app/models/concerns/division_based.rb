module DivisionBased
  extend ActiveSupport::Concern

  included do
    scope :in_division, -> (division) { where(division: division.self_and_descendants) }
  end
end
