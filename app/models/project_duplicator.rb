class ProjectDuplicator
  attr_reader :orig, :copy

  def initialize(orig)
    @orig = orig
  end

  def duplicate
    @copy = orig.amoeba_dup
    copy.original = orig

    duplicate_timeline_entry(orig.root_timeline_entry)

    copy.save!
    copy
  end

  # make sure to set project_id on copy
  def duplicate_timeline_entry(orig_entry, copy_parent_entry = nil)
    copy_entry = orig_entry.amoeba_dup
    copy_entry.project = copy

    # closure_tree doesn't seem to fire properly unless we save here.
    copy_entry.parent = copy_parent_entry
    copy_entry.save!

    orig_entry.children.each do |child|
      duplicate_timeline_entry(child, copy_entry)
    end
  end
end
