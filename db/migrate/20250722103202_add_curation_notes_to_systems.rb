class AddCurationNotesToSystems < ActiveRecord::Migration[8.0]
  def change
    add_column :systems, :curation_notes, :text
  end
end
