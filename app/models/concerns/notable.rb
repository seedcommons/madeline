module Notable
  extend ActiveSupport::Concern     ## consider using SuperModule

  included do
    has_many :notes, as: :notable
  end

  def add_note(text, author)
    note = notes.create(notable: self, author: author, text: text)
  end

end
