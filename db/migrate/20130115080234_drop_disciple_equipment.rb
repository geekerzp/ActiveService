class DropDiscipleEquipment < ActiveRecord::Migration
  def up
    drop_table :disciple_equipments
  end

  def down
    create_table :disciple_equipments
  end
end
