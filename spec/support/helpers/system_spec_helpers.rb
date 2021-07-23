module SystemSpecHelpers
  def reload_page
    page.evaluate_script("window.location.reload()")
  end

  # Waits for the loading indicator to appear and then disappear.
  def wait_for_loading_indicator
    expect(page).to have_content('Loading...')
    expect(page).not_to have_content('Loading...')
    expect(page).not_to have_css('div#glb-load-ind')
  end

  # Fills in the given value into the box with given ID, then selects the first matching option.
  # Assumes a dropdown-style select2 box. Works with a remote data source.
  def select2(value, from:)
    execute_script("$('##{from}').select2('open')")
    find(".select2-search__field").set(value)
    find(".select2-results li", text: /#{value}/).click
  end

  def have_alert(msg, container: 'body')
    have_css("#{container} .alert", text: msg)
  end

  def select_division(division_name)
    within('.user-div-info') do
      find('[data-expands="division-dropdown"]').click
      find('.select_division_form').select(division_name)
    end
  end
end
