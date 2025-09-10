class CreateMetadataNamespaces < ActiveRecord::Migration[8.0]
  def change
    create_table :metadata_namespaces, id: :string, limit: 36   do |t|
      t.string :namespace, null: false
      t.references :metadata_format, null: true, foreign_key: { to_table: 'metadata_formats' }, type: :string, limit: 36
    end
    add_index :metadata_namespaces, :namespace
  end

end
