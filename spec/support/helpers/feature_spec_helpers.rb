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

  shared_examples :flow do
    let(:field_to_change) { 'name' }
    let(:edit_button_name) { "Edit #{model_to_test.model_name.human}" }

    scenario 'should work', js: true do
      visit(polymorphic_path([:admin, model_to_test.class]))
      expect(page).to have_content(model_to_test.name)

      find("##{model_to_test.model_name.plural}").click_link(model_to_test.id)
      expect(page).to have_content(model_to_test.name)
      expect(page).to have_content(edit_button_name)

      find('.edit-action').click
      fill_in("#{model_to_test.model_name.element}[#{field_to_change}]", with: "Changed #{model_to_test.model_name.human} Name")
      click_button "Update #{model_to_test.model_name.human}"
      expect(page).to have_content("Changed #{model_to_test.model_name.human} Name")
      expect(page).to have_content('Record was successfully updated.')
    end
  end
end
