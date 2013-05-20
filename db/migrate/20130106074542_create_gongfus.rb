class CreateGongfus < ActiveRecord::Migration
  def change
    create_table :gongfus, options: 'ENGINE=INNODB, CHARSET=UTF8' do |t|
      t.integer :gf_type
      t.integer :level, default: 0
      t.integer :user_id, default: -1
      t.float :grow_strength, default: 0.0

      t.timestamps
    end
  end
end
