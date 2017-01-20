# == Schema Information
#
# Table name: translations
#
#  created_at             :datetime
#  id                     :integer          not null, primary key
#  locale                 :string
#  text                   :text
#  translatable_attribute :string
#  translatable_id        :integer
#  translatable_type      :string
#  updated_at             :datetime
#
# Indexes
#
#  index_translations_on_translatable_type_and_translatable_id  (translatable_type,translatable_id)
#

class Translation < ActiveRecord::Base
  belongs_to :translatable, polymorphic: true

  delegate :division, :division=, to: :translatable

  def blank?
    text.blank?
  end

  def locale
    read_attribute(:locale).try(:to_sym)
  end

  def to_s
    text
  end
end
