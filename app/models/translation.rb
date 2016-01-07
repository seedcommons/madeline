class Translation < ActiveRecord::Base
  belongs_to :translatable, polymorphic: true
  belongs_to :language
end
