class CreateJianghuRecorders < ActiveRecord::Migration
  def change
    create_table :jianghu_recorders, options: 'ENGINE=INNODB, CHARSET=UTF8' do |t|
      t.integer :user_id, default: -1
      t.integer :scene_id, default: -1
      t.integer :item_id, default: -1
      t.integer :star, default: 0
      t.boolean :is_finish, default: false
      t.integer :failed_time, default: 0

      t.timestamps
    end
  end
end
