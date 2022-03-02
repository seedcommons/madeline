class RenameCensusTrackToCensusTract < ActiveRecord::Migration[6.1]
  def change
    rename_column :organizations, :census_track_code, :census_tract_code
  end
end
