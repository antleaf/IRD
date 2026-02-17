class AddItemCountToSystem < ActiveRecord::Migration[8.1]
  def change
    add_column :systems, :item_count, :integer, default: 0
  end
end
