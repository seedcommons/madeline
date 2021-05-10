module MediaHelper
  def media_thumbnail(media_item)
    if media_item.thumbnail?
      if media_item.caption && !media_item.caption.text.blank?
        image_tag(media_item.item.thumb.url, alt: truncate(media_item.caption.text, length: 36), class: 'media-object')
      else
        image_tag(media_item.item.thumb.url, class: 'media-object')
      end
    else
      content_tag(:div, class: "media-block") do
        concat(content_tag(:div, media_item.kind_value.capitalize))
        concat(icon_tag(media_icon_class(media_item)))
      end
    end
  end

  def attachable_type(media_item)
    attachable = media_item.media_attachable
    if attachable.respond_to?(:type)
      attachable.type
    else
      media_item.media_attachable_type
    end
  end

  def data_export_thumbnail(media_item)
    content_tag(:div, class: "media-block") do
      concat(content_tag(:div, media_title(media_item, length: 20)))
      concat(icon(media_icon_class(media_item)))
    end
  end

  def media_title(media_item, shorten: true, length: 12)
    full_name = File.basename(media_item.item.file.path)

    if shorten
      ext = File.extname(media_item.item.file.path)
      file_name = truncate(File.basename(media_item.item.file.path, ext), length: length)
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

    if caption && caption.text.present?
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
      media_title(media_item, shorten: shorten)
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
      when ".csv"
        "table"
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

  def media_image(media)
    image_tag(media.item.url)
  end
end
