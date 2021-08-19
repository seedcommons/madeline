class FixDivisionDepthsOnQuestions < ActiveRecord::Migration[6.1]
  def up
    # Ensure no groups with children in a higher division
    groups_with_higher_children_query = <<-SQL
      SELECT DISTINCT q.id, q.division_id FROM questions q WHERE EXISTS (
        SELECT id FROM questions cq WHERE cq.parent_id = q.id AND
          (SELECT MAX(generations) FROM division_hierarchies WHERE descendant_id = cq.division_id) <
            (SELECT MAX(generations) FROM division_hierarchies WHERE descendant_id = q.division_id)
      )
    SQL
    unless execute(groups_with_higher_children_query).to_a.empty?
      raise "Group(s) exist with children in higher division. Please correct manually before proceeding."
    end

    problematic_parents_query = <<-SQL
      SELECT DISTINCT q.parent_id
        FROM questions q
        WHERE q.position > 0 AND EXISTS (
          SELECT id
            FROM questions prev_q
            WHERE q.parent_id = prev_q.parent_id
              AND q.position = prev_q.position + 1
              AND q.division_id != prev_q.division_id
              AND (SELECT MAX(generations) FROM division_hierarchies WHERE descendant_id = q.division_id) <=
                (SELECT MAX(generations) FROM division_hierarchies WHERE descendant_id = prev_q.division_id)
        )
    SQL

    rows = execute(problematic_parents_query).to_a
    rows.each do |row|
      parent_id = row["parent_id"]
      puts "Fixing question order in group #{parent_id}"

      fix_position_query = <<-SQL
        UPDATE questions SET position = new_pos FROM (
          SELECT id, ROW_NUMBER() OVER (ORDER BY (
              SELECT MAX(generations) FROM division_hierarchies WHERE descendant_id = division_id
            ), division_id, position) - 1 AS new_pos
          FROM questions
          WHERE parent_id = #{parent_id}
        ) AS t WHERE questions.id = t.id
      SQL
      fix_number_query = <<-SQL
        UPDATE questions SET number = num FROM (
          SELECT id, ROW_NUMBER() OVER (ORDER BY position) AS num
          FROM questions
          WHERE parent_id = #{parent_id} AND active = 't'
        ) AS t WHERE questions.id = t.id
      SQL

      execute(fix_position_query)
      execute(fix_number_query)
    end
  end
end
