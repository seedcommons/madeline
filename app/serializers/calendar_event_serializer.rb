class CalendarEventSerializer < ActiveModel::Serializer
  attributes :start
  attributes :title
  attributes :id

  def title
    object.html
  end
end
