class Media < ActiveRecord::Base
  include Legacy, TranslationModule

  IMAGE_REGEX = /(jpe?g|gif|png|\]|\))$/i
  VIDEO_REGEX = /(mov|avi|wmv|mp4)$/i
  scope :type, ->(type) {
    case type
      when 'image'
        where("MediaPath REGEXP ?", IMAGE_REGEX.source)
      when 'video'
        where("MediaPath REGEXP ?", VIDEO_REGEX.source)
      when 'other'
        where("MediaPath NOT REGEXP ? AND MediaPath NOT REGEXP ?", IMAGE_REGEX.source, VIDEO_REGEX.source)
    end
  }
  def type
    if self.media_path =~ IMAGE_REGEX then 'image'
    elsif self.media_path =~ VIDEO_REGEX then 'video'
    else 'other' end
  end

  def project
    context_table_model = Object.const_get(self.context_table.classify)
    context_table_model.find(self.context_id)
  end

  def path
    base_url = "http://www.theworkingworld.org/"
    return base_url + self.media_path
  end

  def paths
    path = self.path
    # insert various things into file name
    return {
      thumb: path.sub(/(\.[^.]+)$/, '.thumb\1'),
      small: path.sub(/(\.[^.]+)$/, '.small\1'),
      medium: path.sub(/(\.[^.]+)$/, '.medium\1'),
      large: path.sub(/(\.[^.]+)$/, '.large\1')
    }
  end

  def caption
    self.translation('Caption')
  end

  def alt
    self.caption.try(:content) || self.project.try(:name)
  end
end
