require "rails_helper"

# TODO: look for a way around targeting summernote textarea
describe "questionnaire", js: true do
  let(:parent_division) { create(:division) }
  let(:division) { create(:division, parent: parent_division) }
  let(:user) { create_member(division) }
  let(:loan) { create(:loan, division: division) }

  before do
    login_as(user, scope: :user)
  end

  context "with question sets for loan's division" do
    let!(:question_set) do
      # We create the question set on the parent division so that the find_for_division method is being
      # properly used.
      create(:question_set, :with_questions, kind: "loan_criteria", division: parent_division)
    end

    context "with more than one question set for loan's division" do
      let!(:question_set2) do
        create(:question_set, :with_questions, kind: "loan_post_analysis", division: parent_division)
      end

      scenario "works and shows filter switch" do
        visit admin_loan_tab_path(loan, "questions")

        # check that edit-all button turns on edit mode
        expect(page).not_to have_content("Now editing")
        first(".edit-all").click
        expect(page).to have_content("Now editing")

        # cancel button is visible in edit mode
        first("#edit-bar .cancel-edit").click
        expect(page).not_to have_content("Now editing")

        # save changes button is visible in edit mode
        fill_and_save("1337")
        expect(page).to have_css(".view-element", text: "1,337")

        # test outline expansion
        expect(page).not_to have_content("Outline")
        page.find(".outline .expander").click
        expect(page).to have_content("Outline")
        page.find(".outline .hider").click
        expect(page).not_to have_content("Outline")

        # test filter switch and saving non-default questionnaire
        click_on("Post-Analysis")
        expect(page).to have_css("h2", text: "Post-Analysis")
        first(".edit-all").click
        field = find("input[type=number]")
        expect(field.value).to be_blank
        field.set("31337")
        find("body").click
        click_button("Save Changes")
        expect(page).to have_css(".view-element", text: "31,337")
      end
    end

    context "with exactly one question set for loan's division" do
      scenario "doesn't show filter switch" do
        visit admin_loan_tab_path(loan, "questions")
        expect(page).to have_css("h2", text: "Credit Memo")
        expect(page).not_to have_css(".filter-switch")
        fill_and_save("1337")
        expect(page).to have_css(".view-element", text: "1,337")
      end
    end
  end

  context "with no question sets for loan's division" do
    scenario "shows message" do
      visit admin_loan_tab_path(loan, "questions")
      expect(page).to have_content("There are no question sets for this Loan's division")
    end
  end

  context "refactoring to answers table" do
    let!(:question_set) { create(:question_set, kind: "loan_criteria", division: division)}
    let!(:root_q) {create(:question, data_type: "group", question_set: question_set, division: division)}
    let!(:questions) { {} }
    before do
      Question::DATA_TYPES.each do |t|
        questions[t] = Question.create(data_type: t, question_set: question_set, parent: root_q, division: division)
      end
    end

    scenario "custom data and answers table have same info" do
        visit admin_loan_tab_path(loan, "questions")
        first(".edit-all").click
        save_and_open_page
        #page.find('.select', wait: 10, visible: false)
        select_el = page.find("#response_set_#{questions[:boolean].attribute_sym}\\[boolean\\]", wait: 10, visible: false)
        #select_el.find(:xpath, 'option[1]').select_option
        #page.select("Yes", from: "response_set_#{questions[:boolean].attribute_sym}\\[boolean\\]", visible: false)
        find("#response_set_#{questions[:boolean].attribute_sym}\\[boolean\\] option[value='']").click
        find("#response_set_#{questions[:boolean].attribute_sym}\\[boolean\\] option[value='yes']", visible: false).select_option
        fill_qtype_with_value("number", "123")
        fill_qtype_with_value("url", "www.example.com")
        fill_qtype_with_value("start_cell", "A2")
        fill_qtype_with_value("end_cell", "Z100")
        click_button("Save Changes")
        response_set = ResponseSet.find_by(question_set_id: question_set.id)
        response_set.make_answers
        expect(response_set.custom_data).to match_unordered_json(response_set.custom_data_from_answers)
    end
  end

  def fill_qtype_with_value(type, value)
    find("input[type=#{type}]").set(value)
  end

  def fill_and_save(value)
    first(".edit-all").click
    expect(page).to have_content("Now editing")
    find("input[type=number]").set(value)
    find("body").click # Trigger blur event so that Save Changes button is properly clickable
    click_button("Save Changes")
    expect(page).not_to have_content("Now editing")
  end
end
