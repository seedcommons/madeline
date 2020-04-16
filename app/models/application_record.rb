class ApplicationRecord < ActiveRecord::Base
  strip_attributes allow_empty: true

  self.abstract_class = true
end
