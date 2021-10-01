require "rails_helper"

describe "questions flow", js: true do
  let!(:div_a) { create(:division, parent: root_division) }
  let!(:div_b) { create(:division, parent: div_a) }
  let!(:div_c1) { create(:division, parent: div_b) }
  let!(:div_c2) { create(:division, parent: div_b) }
  let!(:div_c3) { create(:division, parent: div_b) }
  let!(:div_d) { create(:division, parent: div_c1) }

  let(:actor) { create_admin(div_a) }

  before do
    login_as(actor, scope: :user)
  end

  context "with question set(s)" do
    # Used by create_question function
    let!(:qset) { create(:question_set, kind: "loan_criteria", division: div_a) }

    # rubocop:disable Layout/IndentationConsistency
    let!(:q0) { create_question(division: div_a, label: "q0", parent: qset.root_group, type: "group") }
      let!(:q00) { create_question(division: div_a, label: "q00", parent: q0, type: "text") }
      let!(:q01) { create_question(division: div_a, label: "q01", parent: q0, type: "text") }
      let!(:q02) { create_question(division: div_b, label: "q02", parent: q0, type: "text") }
      let!(:q03) { create_question(division: div_c1, label: "q03", parent: q0, type: "text") }
    let!(:q1) { create_question(division: div_a, label: "q1", parent: qset.root_group, type: "group") }
      let!(:q10) { create_question(division: div_a, label: "q10", parent: q1, type: "group") }
        let!(:q100) { create_question(division: div_a, label: "q100", parent: q10, type: "text") }
        let!(:q101) { create_question(division: div_a, label: "q101", parent: q10, type: "text") }
        let!(:q102) { create_question(division: div_c2, label: "q102", parent: q10, type: "text") }
        let!(:q103) { create_question(division: div_c2, label: "q103", parent: q10, type: "text") }
        let!(:q104) { create_question(division: div_d, label: "q104", parent: q10, type: "text") }
        let!(:q105) { create_question(division: div_d, label: "q105", parent: q10, type: "text") }
      let!(:q11) { create_question(division: div_b, label: "q11", parent: q1, type: "group") }
        let!(:q110) { create_question(division: div_b, label: "q110", parent: q11, type: "text") }
        let!(:q111) { create_question(division: div_c2, label: "q111", parent: q11, type: "text") }
        let!(:q112) { create_question(division: div_c2, label: "q112", parent: q11, type: "text") }
        let!(:q113) { create_question(division: div_c1, label: "q113", parent: q11, type: "text") }
        let!(:q114) { create_question(division: div_c1, label: "q114", parent: q11, type: "text") }
        let!(:q115) { create_question(division: div_c1, label: "q115", parent: q11, type: "text") }
        let!(:q116) { create_question(division: div_c3, label: "q116", parent: q11, type: "text") }
        let!(:q117) { create_question(division: div_c3, label: "q117", parent: q11, type: "text") }
        let!(:q118) { create_question(division: div_d, label: "q118", parent: q11, type: "text") }
        let!(:q119) { create_question(division: div_d, label: "q119", parent: q11, type: "text") }
    let!(:q2) { create_question(division: div_a, label: "q2", parent: qset.root_group, type: "text") }
    let!(:q3) { create_question(division: div_b, label: "q3", parent: qset.root_group, type: "text") }
    let!(:q4) { create_question(division: div_b, label: "q4", parent: qset.root_group, type: "group") }
      let!(:q40) { create_question(division: div_b, label: "q40", parent: q4, type: "text") }
      let!(:q41) { create_question(division: div_c1, label: "q41", parent: q4, type: "text") }
    let!(:q5) { create_question(division: div_c1, label: "q5", parent: qset.root_group, type: "text") }
    let!(:q6) { create_question(division: div_c1, label: "q6", parent: qset.root_group, type: "group") }
      let!(:q60) { create_question(division: div_c1, label: "q60", parent: q6, type: "text") }
      let!(:q61) { create_question(division: div_c1, label: "q61", parent: q6, type: "text") }
      let!(:q62) { create_question(division: div_c3, label: "q62", parent: q6, type: "text") }
    let!(:q7) { create_question(division: div_c1, label: "q7", parent: qset.root_group, type: "group") }
    let!(:q8) { create_question(division: div_d, label: "q8", parent: qset.root_group, type: "group") }
      let!(:q80) { create_question(division: div_d, label: "q80", parent: qset.root_group, type: "group") }
    # rubocop:enable Layout/IndentationConsistency

    context "with more than one question set for division" do
      let!(:qset2) { create(:question_set, kind: "loan_post_analysis", division: div_a) }
      let!(:qset2_q) do
        create_question(division: div_a, label: "qset2_q", parent: qset2.root_group, type: "text", set: qset2)
      end

      scenario "index, create, update, destroy" do
        visit(root_path)
        select_division(div_c1.name)
        visit(admin_questions_path)

        # Tooltips work
        first(".fa-lock").hover
        expect(page).to have_content("is not owned by the currently selected division")

        # Expansion works and correct questions shown
        expand_group(q0)
        expect(page).to have_content("q00")
        expect(page).to have_content("q03")
        expand_group(q1)
        expect(page).to have_content("q10")
        expand_group(q10)
        expect(page).to have_content("q105")
        expand_group(q11)
        expect(page).to have_content("q115")
        expect(page).not_to have_content("q116")
        expand_group(q4)
        expect(page).to have_content("q41")
        expand_group(q6)
        expect(page).to have_content("q61")
        expect(page).not_to have_content("qset2_q")

        # 'Add question' links in correct places
        expect(page).to have_css(%([data-id="#{q0.id}"] a.new-action))
        expect(page).not_to have_css(%([data-id="#{q8.id}"] a.new-action))

        click_on("Post-Analysis")
        expect(page).to have_content("qset2_q")
        expect(page).not_to have_content("q115")

        # Tree expansions are remembered
        click_on("Credit Memo")
        expect(page).to have_content("q115")

        # Create question
        find(%([data-id="#{q11.id}"] a.new-action)).click
        fill_in("Title", with: "Stuff")
        click_button("Save")

        expect(page).to have_content("Errors prevented the record from being saved.", wait: 20)
        select("Number", from: "Data Type")
        click_button("Save")

        expect(page).to have_css(".jqtree-title", text: "Stuff", wait: 20)
        expect(page).to have_content("6. q115\n7. Stuff\n10. q118")

        find(%([data-id="#{q113.id}"] > .jqtree-element .edit-action)).click
        fill_in("Title", with: "Stonks")
        click_button("Save")

        expect(page).to have_css(".jqtree-title", text: "Stonks", wait: 20)
        expect(page).not_to have_css(".jqtree-title", text: "q113")

        accept_confirm { find(%([data-id="#{q113.id}"] > .jqtree-element .delete-action)).click }
        expect(page).not_to have_css(".jqtree-title", text: "Stonks")
      end

      scenario "in 'All Divisions' mode, don't allow" do
        visit(admin_person_path(actor)) # Don't start at the root path b/c that's where we get redirected.

        within("#site-menu") do
          find("a", text: "Manage").click
          expect(page).to have_content("Accounting Settings") # Wait for dropdown to show
          expect(page).not_to have_content("Questions")
        end

        visit(admin_questions_path)
        expect(page).to have_current_path("/admin/dashboard")
      end
    end

    context "with just one question set for division" do
      scenario "still works and shows filter switch" do
        visit(root_path)
        select_division(div_c1.name)
        visit(admin_questions_path)
        expect(page).to have_css(".filter-switch", text: "Credit Memo")
        expect(page).to have_content("q0")
      end
    end
  end

  context "with no question sets for division" do
    scenario "shows message" do
      visit(root_path)
      select_division(div_a.name)
      visit(admin_questions_path)
      expect(page).to have_content("There are no question sets for the currently selected division")
    end
  end

  def expand_group(group)
    find(%([data-id="#{group.id}"] > .jqtree-element > .jqtree-toggler)).click
  end
end
