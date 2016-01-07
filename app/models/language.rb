# == Schema Information
#
# Table name: languages
#
#  id         :integer          not null, primary key
#  name       :string
#  code       :string
#  created_at :datetime
#  updated_at :datetime
#

class Language < ActiveRecord::Base
  def self.for_locale(locale: nil)
    locale ||= I18n.locale
    language_code = locale.to_s[0..1].upcase
    language = Language.find_by(code: language_code)
  end
end
