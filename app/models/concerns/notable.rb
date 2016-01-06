module Notable
  extend ActiveSupport::Concern     ## consider using SuperModule

  included do
    has_many :notes, as: :notable
  end


end


