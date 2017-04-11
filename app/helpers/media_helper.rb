module MediaHelper
  def media_thumbnail(media_item)
    if media_item.thumbnail?
      image_tag(media_item.item.thumb.url)
    else
      # media_extension = File.extname(media_item.item.file.path).downcase
      # # content_tag(:div, class: "generic-thumbnail") do
      # content_tag(:div, media_extension, class: "extension")
      # # concat(image_tag("file-blank.png"))
      # # end
      content_tag(:div, class: "media-block") do
        concat(content_tag(:div, media_item.kind_value.capitalize))
        concat(sanitize("<i class='fa fa-#{media_icon_class(media_item)}'></i>", tags: %w(i),
          attributes: %w(class)))
      end
    end
  end

  def media_title(media_item)
    ext = File.extname(media_item.item.file.path)
    file_name = truncate(File.basename(media_item.item.file.path, ext), length: 12)
    content_tag(:div, class: "media-title") do
      concat(content_tag(:span, file_name))
      concat(content_tag(:div, ext.downcase))
    end
  end

  def media_icon_class(media_item)
    if media_item.visual_media?
      if media_item.kind_value.downcase == "video"
        "file-video-o"
      else
        "file-image-o"
      end
    else
      case ext = File.extname(media_item.item.file.path)
      when ".pdf"
        icon_class = "file-pdf-o"
      when ".doc"
        icon_class = "file-word-o"
      when ".docx"
        icon_class = "file-word-o"
      else
        icon_class = "file-text-o"
      end
      return icon_class
    end
  end
end
