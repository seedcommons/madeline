# TS, 7/23/21: I think we should deprecate this file and move the testing logic into each
# feature spec, since each page is slightly different and there are different things we want to test
# in each one. I also don't think we need to be testing the change division flow for every module.
shared_examples "flow" do
  let(:field_to_change) { 'name' }
  let(:edit_button_name) { "Edit #{subject.model_name.human}" }

  scenario 'can index/show/edit and change division', js: true do
    visit(polymorphic_path([:admin,subject.class]))

    # Now test index/show/edit
    expect(page).to have_content(subject.name)

    find("##{subject.model_name.plural}").click_link(subject.id.to_s)
    expect(page).to have_content(subject.name)
    expect(page).to have_content(edit_button_name)

    find('.edit-action').click
    expect(page).to have_css("##{subject.model_name.element}_#{field_to_change}", visible: true)
    fill_in("#{subject.model_name.element}[#{field_to_change}]", with: "Changed #{subject.model_name.human} Name")

    # hack since we are changing Organization (table name) to Co-op (new string)
    model_name = subject.model_name.human == 'Organization' ? 'Co-op' : subject.model_name.human
    click_button "Update #{model_name}"

    expect(page).to have_content("Changed #{subject.model_name.human} Name")
    expect(page).to have_content('Record was successfully updated.')
  end
end
