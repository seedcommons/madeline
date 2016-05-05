class CalendarEventSerializer < ActiveModel::Serializer
  # Beware, this 'root = false' doesn't seem to have an effect.
  # JE Todo: Understand why.
  self.root = false

  attributes :start
  attributes :title

  def title
    object.html
  end
end
