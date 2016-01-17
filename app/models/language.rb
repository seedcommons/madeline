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
  # returns language_id for given code
  def self.resolve_id(code = nil)
    code ||= I18n.language_code
    result = Language.where(code: code.upcase).first.try(:id)
    raise ArgumentError, "Language code: #{code} not found"  unless result
    # todo: confirm if we should failfast or adapt to missing configuration data here
    # unless result
    #   result = system_default
    #   Rails.logger.warn("Language code: #{code} not found, using system default: #{result.code}")
    #   puts "Language code: #{code} not found, using system default: #{result.code}"
    # end
    result
  end

  #future: use a cache here also if this class is kept
  def self.resolve_code(id)
    Language.find(id).try(:code)
  end

  # todo: confirm if this is acceptable to define here.
  def self.system_default
    self.first || self.create(name: 'English', code: 'EN')
  end


end

module I18n
  # Convert locale code to language code used by database
  def self.language_code
    result = locale.to_s[0,2].upcase
    result
  end
end
