module MediaHelper
  def media_thumbnail(media_item)
    if media_item.thumbnail?
      image_tag(media_item.item.thumb.url)
    else
      media_extension = File.extname(media_item.item.file.path).downcase
      # content_tag(:div, class: "generic-thumbnail") do
        content_tag(:div, media_extension, class: "extension")
        # concat(image_tag("file-blank.png"))
      # end
    end
  end
end
