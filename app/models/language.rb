class Language < ActiveRecord::Base
  # returns language_id for given code
  def self.resolve_id(code = nil)
    code ||= I18n.language_code
    result = Language.where({code: code.upcase}).first.try(:id)  #JE todo: use a cache to optimize once unit tests are in place
    #JE todo: have a discussion to confirm if this should be fatal at this level and what excpetion type to raise
    raise ArgumentError, "Language code: #{code} not found"  unless result
    result
  end

  #todo: use a cache here also
  def self.resolve_code(id)
    Language.find(id).try(:code)
  end

end

module I18n
  # Convert locale code to language code used by database
  def self.language_code
    result = locale.to_s[0,2].upcase
    result
  end
end
