module DataExportsHelper
  def display_attachments_list(data_export)
    if data_export.attachments.length > 0
      text = ""
      data_export.attachments.each do |attachment|
        text += "<p class='attachment'><a href='#{attachment.item}'>"
        text += "<i class='fa fas fa-download'></i>"
        text += "<span>#{I18n.t('data_export.download')}</span>"
        text += "</a></p>"
      end
      return sanitize(text, tags: %w(a p i span), attributes: %w(class href))
    end
  end
end
