class CreateContinuousLoginRewards < ActiveRecord::Migration
  def change
    create_table :continuous_login_rewards, options: 'ENGINE=INNODB, CHARSET=UTF8' do |t|
      t.integer :user_id
      t.string :reward_1_type
      t.string :reward_2_type
      t.string :reward_3_type
      t.integer :continuous_login_time
      t.integer :receive_or_not

      t.timestamps
    end
  end
end
