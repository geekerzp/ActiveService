class AddPositionToEquipment < ActiveRecord::Migration
  def change
    add_column :equipment, :position, :integer, :default => -1
  end
end
