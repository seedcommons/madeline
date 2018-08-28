$(document).on('ready', function() {
  // summernote on pages
  $('[data-provider="summernote"]').each(function() {
    $(this).summernote({
      height: 300,
      toolbar: [
        ["style", ["bold", "italic", "underline", "clear"]],
        ["table", ["table"]],
        ["para", ["ul", "ol", "paragraph"]]
      ]
    });
  });

  // summernote on question edit modal
  $('#edit-modal').on( "show.bs.modal", function() {
    $('#question_explanation').summernote({
      dialogsInBody: true,
      height: 150,
      toolbar: [
        ["style", ["bold", "italic", "underline", "clear"]],
        ["table", ["table"]],
        ["para", ["ul", "ol", "paragraph"]]
      ]
    })
  });

  $('.note-editor').addClass('form-element');
});
