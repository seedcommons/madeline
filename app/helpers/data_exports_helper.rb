module DataExportsHelper
  def display_attachments_list(data_export)
    text = ""

    if data_export.attachments.length > 0
      media_count = 1
      data_export.attachments.each do |attachment|
        text += "<p><a href='#{attachment.item}'>File #{media_count}</a></p>"
        media_count  += 1
      end
    end

    return text.html_safe
  end
end
