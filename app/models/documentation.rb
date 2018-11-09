# == Schema Information
#
# Table name: documentations
#
#  calling_action     :string
#  calling_controller :string
#  created_at         :datetime         not null
#  division_id        :bigint(8)
#  html_identifier    :string
#  id                 :bigint(8)        not null, primary key
#  previous_url       :string
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_documentations_on_division_id      (division_id)
#  index_documentations_on_html_identifier  (html_identifier) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (division_id => divisions.id)
#

class Documentation < ApplicationRecord
  include DivisionBased
  include Translatable

  belongs_to :division

  translates :summary_content, :page_content, :page_title

  validates :html_identifier, uniqueness: true
end
