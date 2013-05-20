class AddDiscipleidToEquipment < ActiveRecord::Migration
  def change
    add_column :equipment, :disciple_id, :integer
  end
end
