class CalendarEventSerializer < ActiveModel::Serializer
  # Beware, this 'root = false' doesn't seem to have an effect.
  # JE Todo: Understand why.
  self.root = false

  attributes :start
  attributes :title
  attributes :id

  def id
    "#{object.event_type}-#{object.model_id}"
  end

  # def title
  #   object.html
  # end
end
