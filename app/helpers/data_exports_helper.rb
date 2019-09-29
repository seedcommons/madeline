module DataExportsHelper
  def display_attachments_list(data_export)
    text = ""
    if data_export.attachments.length > 0
      text = "Attachments Present"
      # data_export.attachments.each do |attachment|
      #   attachment.item
    else
      text = "No Attachments"
    end

    return text
  end
end
