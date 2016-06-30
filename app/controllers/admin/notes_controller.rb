class Admin::NotesController < Admin::AdminController
  before_action :set_note, only: [:show, :edit, :update, :destroy]

  def new
    @note = Note.new
    authorize @note
    render partial: 'note', locals: { mode: :form }
  end

  def edit
    render nothing: true
  end

  def create
    @note = Note.new(note_params)

    if @note.save
      render json: @note, status: :created
    else
      render json: @note.errors, status: :unprocessable_entity
    end
  end

  def update
    respond_to do |format|
      if @note.update(note_params)
        format.html { redirect_to @note, notice: 'Note was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @note.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @note.destroy
    respond_to do |format|
      format.html { redirect_to notes_url }
      format.json { head :no_content }
    end
  end

  private
    def set_note
      @note = Note.find(params[:id])
      authorize @note
    end

    def note_params
      params.require(:note).permit(:text)
    end
end
