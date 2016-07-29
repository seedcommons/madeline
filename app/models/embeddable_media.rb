# == Schema Information
#
# Table name: embeddable_media
#
#  created_at   :datetime         not null
#  height       :integer
#  html         :text
#  id           :integer          not null, primary key
#  original_url :string
#  updated_at   :datetime         not null
#  url          :string
#  width        :integer
#

class EmbeddableMedia < ActiveRecord::Base
end
