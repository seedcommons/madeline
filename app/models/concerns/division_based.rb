module DivisionBased
  extend ActiveSupport::Concern

  included do
    def self.in_division(division)
      division ? where(division: division.self_and_descendants) : all
    end

    # For wicegrid custom filters
    def self.filter_in_division(division, order: :name)
      in_division(division).order(order).map { |i| [i.name, i.id] }
    end
  end
end
