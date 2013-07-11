class CreateDisciples < ActiveRecord::Migration
  def change
    create_table :disciples, options: 'ENGINE=INNODB, CHARSET=UTF8' do |t|
      t.integer :user_id, default: -1
      t.integer :level, default: 1
      t.integer :experience, default: 0
      t.integer :d_type, default: -1
      t.float :grow_blood, default: 0.0
      t.float :grow_attack, default: 0.0
      t.float :grow_defend, default: 0.0
      t.float :grow_internal, default: 0.0

      t.timestamps
    end
  end
end
