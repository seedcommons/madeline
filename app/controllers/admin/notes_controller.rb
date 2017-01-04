class Admin::NotesController < Admin::AdminController
  before_action :set_note, only: [:show, :edit, :update, :destroy]

  # def new
  #   @note = Note.new
  #   authorize @note
  #   render partial: 'note', locals: { mode: :form }
  # end

  def create
    @note = Note.new(note_params.merge author: current_user.profile)
    authorize @note

    if @note.save
      render partial: 'show', locals: { note: @note.reload }
    else
      render partial: 'form', status: :unprocessable_entity, locals: { note: @note }
    end
  end

  def update
    if @note.update(note_params)
      render partial: 'show', locals: { note: @note.reload }
    else
      render partial: 'form', status: :unprocessable_entity, locals: { note: @note }
    end
  end

  def destroy
    @note.destroy
    head :no_content
  end

  private
    def set_note
      @note = Note.find(params[:id])
      authorize @note
    end

    def note_params
      params.require(:note).permit(:text, :notable_id, :notable_type)
    end
end
