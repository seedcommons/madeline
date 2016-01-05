class PopulateRootDivision < ActiveRecord::Migration
  def up
    # note, we'll likely want to create a parent division specific to The Working World, and may not eventually
    # need this system wide root.  Will revisit once full requirements are more clear.
    Division.create({id:Division.root_id, name:'Root Division'})
    Division.connection.execute("select setval('divisions_id_seq', greatest((select max(id)+1 from divisions), #{Division.root_id+1}))")
  end

  def down
    Division.where(id: Division.root_id).destroy_all
  end
end
