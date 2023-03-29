class EnsureInternalNamesContainField < ActiveRecord::Migration[6.1]

  # In the move from json blob to Answer table, need a way
  # to distinguish internal_name form keys from other form keys
  # when saving Answers data. This supports that need, and
  # internal_name will be removed entirely in a following release.

  def up
    Question.find_each do |q|
      if !q.internal_name.include?("field")
        q.update(internal_name: "#{q.internal_name}_field")
      end
    end
  end

  def down
    # do nothing, not a problem if they do contain field
  end
end
