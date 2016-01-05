class PopulateRootDivision < ActiveRecord::Migration
  def up
    # note, we'll likely want to create a parent division specific to The Working World, and may not eventually
    # need this system wide root.  Will revisit once full requirements are more clear.
    Division.create({id:Division::ROOT_ID, name:'Root Division'})
    Division.connection.execute("select setval('divisions_id_seq', greatest((select max(id)+1 from divisions), 100))")
  end

  def down
    Division.find(Division::ROOT_ID).destroy
  end
end
