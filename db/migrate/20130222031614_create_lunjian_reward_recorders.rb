class CreateLunjianRewardRecorders < ActiveRecord::Migration
  def change
    create_table :lunjian_reward_recorders, options: 'ENGINE=INNODB, CHARSET=UTF8'  do |t|
      t.integer :user_id, default: -1
      t.integer :position, default: -1
      t.integer :reward, default: -1

      t.timestamps
    end
  end
end
