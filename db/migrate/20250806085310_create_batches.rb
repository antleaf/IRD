class CreateBatches < ActiveRecord::Migration[8.0]
  def change
    create_table :batches do |t|
      t.string :filename, limit: 100
      t.references :user, null: false, type: :string, limit: 36, foreign_key: true
      t.references :rp, null: true, foreign_key: { to_table: 'organisations' }, type: :string, limit: 36
      t.boolean :locking
      t.text :notes

      t.timestamps
    end
  end
end
