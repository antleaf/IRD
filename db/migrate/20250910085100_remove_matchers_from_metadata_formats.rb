class RemoveMatchersFromMetadataFormats < ActiveRecord::Migration[8.0]
  def change
    remove_index :metadata_formats, :match_order
    remove_column :metadata_formats, :matchers, :string
    remove_column :metadata_formats, :match_order, :float
  end
end
