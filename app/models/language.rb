class Language < ActiveRecord::Base

  # create_table :languages do |t|
  #   t.string :name
  #   t.string :code
  #
  #   t.timestamps


  # returns language_id for given code
  def self.resolve_id(code = nil)
    code ||= I18n.language_code
    Language.where({code: code.upcase}).first.try(:id)  #todo: use a cache to optimize
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

