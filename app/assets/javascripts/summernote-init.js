$(document).on('ready', function() {
  $('[data-provider="summernote"]').each(function() {
    $(this).summernote({
      height: 300,
      toolbar: [
        ["style", ["bold", "italic", "underline", "clear"]],
        ["insert", ["table", "picture", "link"]],
        ["para", ["ul", "ol", "paragraph"]]
      ]
    });
  });

  $('.note-editor').addClass('form-element');
});
