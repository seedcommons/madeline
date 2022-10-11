class RemoveLikelihoodClosing < ActiveRecord::Migration[6.1]
  def change
    remove_column :projects, :likelihood_closing, :string, default: "not_applicable", null: false
  end
end
