module DataExportsHelper
  def display_attachments_list(data_export)
    text = ""
    if data_export.attachments.length > 0
      media_count = 1
      text = "<ul>"
      data_export.attachments.each do |attachment|
        text += "<li><a href='#{attachment.item}'>File #{media_count}</a></li>"
        media_count  += 1
      end
      text += "</ul>"
    else
      text = "No Attachments"
    end

    return text.html_safe
  end
end
