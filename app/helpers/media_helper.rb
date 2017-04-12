module MediaHelper
  def media_thumbnail(media_item)
    if media_item.thumbnail?
      image_tag(media_item.item.thumb.url)
    else
      content_tag(:div, class: "media-block") do
        concat(content_tag(:div, media_item.kind_value.capitalize))
        concat(icon(media_icon_class(media_item)))
      end
    end
  end

  def media_title(media_item)
    ext = File.extname(media_item.item.file.path)
    file_name = truncate(File.basename(media_item.item.file.path, ext), length: 12)
    full_name = File.basename(media_item.item.file.path)
    content_tag(:div, class: "media-title", title: full_name) do
      concat(content_tag(:span, file_name))
      concat(content_tag(:div, ext.downcase))
    end
  end

  def media_icon_class(media_item)
    if media_item.visual?
      if media_item.kind_value == "video"
        "file-video-o"
      else
        "file-image-o"
      end
    else
      case ext = File.extname(media_item.item.file.path)
      when ".pdf"
        "file-pdf-o"
      when ".doc"
        "file-word-o"
      when ".docx"
        "file-word-o"
      else
        "file-text-o"
      end
    end
  end
end
