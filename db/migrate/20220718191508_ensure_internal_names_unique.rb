class EnsureInternalNamesUnique < ActiveRecord::Migration[6.1]
  def up
    special_internal_names = ["poc_ownership_percent", "cooperative_members", "women_ownership_percent", "environmental_impact_score"]
    Question.find_each do |q|
      if q.internal_name.include?("field")
        q.update(internal_name: "#{q.internal_name}_#{q.id}")
      end
      if special_internal_names.include?(q.internal_name)
        q.update(internal_name: "#{q.internal_name}_#{q.id}")
      end
    end
    add_index :questions, :internal_name, unique: true
  end

  def down
    special_internal_names = ["poc_ownership_percent", "cooperative_members", "women_ownership_percent", "environmental_impact_score"]
    Question.find_each do |q|
      if q.internal_name.include?("field") || special_internal_names.include?(q.internal_name)
        q.update(internal_name: q.internal_name.gsub("_#{q.id}", ""))
      end
    end
    remove_index :questions, column: [:internal_name]
  end
end
