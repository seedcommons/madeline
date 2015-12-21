class Translation < ActiveRecord::Base
  include TranslationModule

  belongs_to :language, :foreign_key => 'Language'

  alias_attribute :content, :TranslatedContent
end
