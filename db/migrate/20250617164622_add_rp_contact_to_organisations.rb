class AddRpContactToOrganisations < ActiveRecord::Migration[8.0]
  def change
    add_column :organisations, :rp_contact, :string
  end
end
