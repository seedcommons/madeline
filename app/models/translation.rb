# == Schema Information
#
# Table name: translations
#
#  id                     :integer          not null, primary key
#  translatable_id        :integer
#  translatable_type      :string
#  translatable_attribute :string
#  language_id            :integer
#  text                   :text
#  created_at             :datetime
#  updated_at             :datetime
#
# Indexes
#
#  index_translations_on_language_id                            (language_id)
#  index_translations_on_translatable_type_and_translatable_id  (translatable_type,translatable_id)
#

class Translation < ActiveRecord::Base
  belongs_to :translatable, polymorphic: true
  belongs_to :language
end
