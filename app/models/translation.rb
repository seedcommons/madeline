class Translation < ActiveRecord::Base
  include Legacy, TranslationModule

  # language column made accessible by Legacy module interferes with language method below
  remove_method :language

  belongs_to :language, :foreign_key => 'Language'

  alias_attribute :content, :TranslatedContent
end
