class CreateZhangmenjues < ActiveRecord::Migration
  def change
    create_table :zhangmenjues, options: 'ENGINE=INNODB, CHARSET=UTF8' do |t|
      t.integer :z_type
      t.integer :level, default: 0
      t.integer :poli, default: 0
      t.integer :score, default: 0
      t.integer :user_id, default: -1

      t.timestamps
    end
  end
end
