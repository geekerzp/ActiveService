class CreateEquipment < ActiveRecord::Migration
  def change
    create_table :equipment, options: 'ENGINE=INNODB, CHARSET=UTF8' do |t|
      t.integer :e_type, default: -1
      t.integer :level, default: 1
      t.integer :user_id, default: -1
      t.float :grow_strength, default: 0.0

      t.timestamps
    end
  end
end
