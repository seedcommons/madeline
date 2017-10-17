module MediaHelper
  def media_thumbnail(media_item)
    if media_item.thumbnail?
      if media_item.caption.text.present?
        alt_text = truncate(media_item.caption.text, length: 36)
        return image_tag(media_item.item.thumb.url, alt: alt_text)
      else
        # Use auto-generated alt text
        return image_tag(media_item.item.thumb.url)
      end
    else
      content_tag(:div, class: "media-block") do
        concat(content_tag(:div, media_item.kind_value.capitalize))
        concat(icon(media_icon_class(media_item)))
      end
    end
  end

  def media_title(media_item, shorten: true)
    full_name = File.basename(media_item.item.file.path)

    if shorten
      ext = File.extname(media_item.item.file.path)
      file_name = truncate(File.basename(media_item.item.file.path, ext), length: 12)
      content_tag(:div, class: "media-title", title: full_name) do
        concat(content_tag(:span, file_name))
        concat(content_tag(:div, ext.downcase))
      end
    else
      content_tag(:div, class: "media-title") do
        concat(content_tag(:span, full_name))
      end
    end
  end

  def media_caption(media_item, shorten: true)
    caption = media_item.send("caption_#{I18n.locale}")

    if caption && caption.text && !caption.text.empty?
      if shorten
        content_tag(:div, class: "media-title media-caption") do
          concat(content_tag(:span, truncate(caption.text, length: 26)))
        end
      else
        content_tag(:div, class: "media-title media-caption") do
          concat(content_tag(:span, caption.text))
        end
      end
    else
      media_title(media_item)
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

  def media_visuals(media)
    media.select do |media_item| media_item.visual? end
  end

  def media_documents(media)
    media.select do |media_item| !media_item.visual? end
  end
end
