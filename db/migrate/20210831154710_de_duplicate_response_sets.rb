class DeDuplicateResponseSets < ActiveRecord::Migration[6.1]

  # NOTE: up/down is written such that rollback can be run immediately to undo the up changes and vica versa,
  # preserving which response set is the 'non-dup.'
  # If up runs, then down runs, and then response sets are updated some other way (e.g. via the UI),
  # up may not set the same response set as the non-dup as the first time.
  def up
    Loan.find_each do |loan|
      kinds_present = loan.response_sets.map { |r| r.kind }.uniq
      kinds_present.each do |kind|
        dup_responses = loan.response_sets.select { |r| r.kind == kind }
        sorted_dups = dup_responses.sort_by { |r| [r.updated_at, r.id] }
        last_index_to_change = sorted_dups.count - 2 # last index is num_dups-1. Don't change last index.
        for i in (0..last_index_to_change) do
          dup = sorted_dups[i]
          new_kind = "#{dup.kind}-dup-#{i}"
          log_str = "For loan #{loan.id}: Updating response set id #{dup.id} (last updated at #{dup.updated_at}) kind from #{dup.kind} to #{new_kind}"
          say_with_time log_str do
            dup.update(kind: new_kind)
          end
        end
      end
    end
  end

  def down
    Loan.find_each do |loan|
      loan_responses = loan.response_sets
      regex = /\-dup\-[0-9]+/
      responses_to_keep_most_recent = []
      unless loan_responses.count < 2 # don't change last_updated on responses for loans that have only one of any kind
        loan_responses.each do |r|
          if r.kind.match(regex)
            old_kind = r.kind.sub(regex, "")
            log_str = "For loan #{loan.id}: Updating response set id #{r.id} (last updated at #{r.updated_at}) kind from #{r.kind} to #{old_kind}"
            say_with_time log_str do
              r.update(kind: old_kind)
            end
          else
            responses_to_keep_most_recent.append(r)
          end
        end
        responses_to_keep_most_recent.each do |r| #aka 'non dup responses'
          log_str = "For loan #{loan.id}: Making response set id #{r.id} with kind #{r.kind} most recently updated"
          say_with_time log_str do
            r.touch
          end
        end
      end
    end
  end
end
