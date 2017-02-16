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
    let(:edit_button_name) { "Edit #{subject.model_name.human}" }

    scenario 'can index/show/edit and change division', js: true do
      visit(polymorphic_path([:admin,subject.class]))

      # Make sure we can change divisions
      expect(find('[data-expands="division-dropdown"]')).to have_content 'Select Division'

      # Change to specific division, and ensure the page reloads properly
      find('[data-expands="division-dropdown"]').click
      find('.select_division_form').select(division.name)
      expect(find('[data-expands="division-dropdown"]')).to have_content 'Change Division'
      expect(find('.without-logo')).to have_content division.name

      # Change back to all divisions, and ensure it reloads properly
      find('[data-expands="division-dropdown"]').click
      find('.select_division_form').select('All Divisions')
      expect(find('.madeline')).to have_content 'Madeline'
      expect(find('[data-expands="division-dropdown"]')).to have_content 'Select Division'

      # Now test index/show/edit
      expect(page).to have_content(subject.name)

      find("##{subject.model_name.plural}").click_link(subject.id)
      expect(page).to have_content(subject.name)
      expect(page).to have_content(edit_button_name)

      find('.edit-action').click
      expect(page).to have_css("##{subject.model_name.element}_#{field_to_change}", visible: true)
      fill_in("#{subject.model_name.element}[#{field_to_change}]", with: "Changed #{subject.model_name.human} Name")
      click_button "Update #{subject.model_name.human}"
      expect(page).to have_content("Changed #{subject.model_name.human} Name")
      expect(page).to have_content('Record was successfully updated.')

    end
  end
end
