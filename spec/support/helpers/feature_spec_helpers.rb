module FeatureSpecHelpers
  def reload_page
    page.evaluate_script("window.location.reload()")
  end

  # Fills in the given value into the box with given ID, then selects the first matching option.
  # Assumes a dropdown-style select2 box. Works with a remote data source.
  def select2(value, from:)
    execute_script("$('##{from}').select2('open')")
    find(".select2-search__field").set(value)
    find(".select2-results li", text: /#{value}/).click
  end
end
