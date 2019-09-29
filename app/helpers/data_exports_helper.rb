module DataExportsHelper
  def display_attachments_list(data_export)
    if data_export.attachments.length > 0
      text = ""
      media_count = 1
      data_export.attachments.each do |attachment|
        text += "<p><a href='#{attachment.item}'>#{t('data_export.file', n: media_count.to_s)}"
        text += "</a></p>"
        media_count += 1
      end
      return text.html_safe
    end
  end
end
