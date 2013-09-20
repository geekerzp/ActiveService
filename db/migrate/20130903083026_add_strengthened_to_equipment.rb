class AddStrengthenedToEquipment < ActiveRecord::Migration
  def change
    add_column :equipment, :strengthened_token, :string
  end
end
