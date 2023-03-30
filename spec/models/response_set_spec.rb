require 'rails_helper'

describe ResponseSet do
  let(:division) { create(:division) }
  let!(:question_set) { create(:question_set, :with_questions, kind: "loan_criteria", division: division)}
  let(:loan) { create(:loan, division: division) }

  describe "embedded urls" do
    
  end

  describe "question_blank?" do
    context "answer to this question is blank" do
      it "should be true" do

      end
    end

    context "answer to this question exists" do
      it "should be false" do

      end
    end

    context "only one grandchild question is answered" do
       it "should be false" do
       end
    end

    context "this quesion is a group that has groups but no descendent qs are answered" do
       it "should be true" do
       end
    end
  end
end
