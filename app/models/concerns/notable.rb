module Notable
  extend ActiveSupport::Concern     ## consider using SuperModule

  included do
    has_many :notes, as: :notable
  end

  def add_note(text, author)
    #JE todo: figure out a clever way to support providing translatable values directly with the create map
    note = notes.create({ notable: self, author: author })
    note.set_text(text)
  end

end


