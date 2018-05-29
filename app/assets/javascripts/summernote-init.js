$(document).on('ready', function() {
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

  $('.note-editor').addClass('form-element');
});
