class CreateDiscipleEquipments < ActiveRecord::Migration
  def change
    create_table :disciple_equipments, options: 'ENGINE=INNODB, CHARSET=UTF8' do |t|
      t.integer :disciple_id, default: -1
      t.integer :equipment_id, default: -1

      t.timestamps
    end
  end
end
