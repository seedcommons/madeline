# == Schema Information
#
# Table name: embeddable_media
#
#  created_at      :datetime         not null
#  document_key    :string
#  end_cell        :string
#  height          :integer
#  html            :text
#  id              :integer          not null, primary key
#  original_url    :string
#  owner_attribute :string
#  owner_id        :integer
#  owner_type      :string
#  sheet_number    :string
#  start_cell      :string
#  updated_at      :datetime         not null
#  url             :string
#  width           :integer
#
# Indexes
#
#  index_embeddable_media_on_owner_type_and_owner_id  (owner_type,owner_id)
#

class EmbeddableMedia < ActiveRecord::Base
end
