module TranslationSaveable
  extend ActiveSupport::Concern

  def translation_params(*attribs)
    attribs.map do |a|
      I18n.available_locales.map { |l| [:"#{a}_#{l}", :"clear_#{a}_#{l}"] }
    end.flatten + [{:deleted_locales => []}]
  end
end
