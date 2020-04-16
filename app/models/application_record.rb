class ApplicationRecord < ActiveRecord::Base
  strip_attributes

  self.abstract_class = true
end
