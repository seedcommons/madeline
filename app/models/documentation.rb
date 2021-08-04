class Documentation < ApplicationRecord
  include DivisionBased
  include Translatable

  belongs_to :division

  translates :summary_content, :page_content, :page_title

  validates :html_identifier, uniqueness: true
end
