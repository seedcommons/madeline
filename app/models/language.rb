# == Schema Information
#
# Table name: languages
#
#  created_at :datetime
#  id         :integer          not null, primary key
#  locale     :string
#  name       :string
#  updated_at :datetime
#

class Language < ActiveRecord::Base
end
