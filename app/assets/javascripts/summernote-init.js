$(document).on('ready', function() {
  return $('[data-provider="summernote"]').each(function() {
    return $(this).summernote({
      height: 300
    });
  });
});
