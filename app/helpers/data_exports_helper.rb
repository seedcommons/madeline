module DataExportsHelper
  def display_attachments_list(data_export)
    if data_export.attachments.length > 0
      text = ""
      data_export.attachments.each do |attachment|
        text += "<p><a href='#{attachment.item}'>"
        text += "#{media_title(attachment, shorten: true, length: 12)}"
        text += "</a></p>"
      end
      return sanitize(text, tags: %w(a p), attributes: %w(href))
    end
  end
end
