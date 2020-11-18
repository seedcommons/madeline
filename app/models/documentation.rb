# == Schema Information
#
# Table name: documentations
#
#  id                 :bigint           not null, primary key
#  calling_action     :string
#  calling_controller :string
#  html_identifier    :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  division_id        :bigint
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
