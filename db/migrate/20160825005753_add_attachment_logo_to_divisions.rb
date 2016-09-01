class AddAttachmentLogoToDivisions < ActiveRecord::Migration
  def self.up
    change_table :divisions do |t|
      t.attachment :logo
    end
  end

  def self.down
    remove_attachment :divisions, :logo
  end
end
