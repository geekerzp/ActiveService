class CreateJianghuRewardRecorders < ActiveRecord::Migration
  def change
    create_table :jianghu_reward_recorders, options: 'ENGINE=INNODB, CHARSET=UTF8' do |t|
      t.integer :user_id
      t.integer :scene_id
      t.string :reward

      t.timestamps
    end
  end
end
