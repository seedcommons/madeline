class LoanQuestionSerializer < ActiveModel::Serializer
  attributes :name

  def name
    object.label.to_s
  end
end
