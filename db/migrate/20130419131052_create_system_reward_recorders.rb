class CreateSystemRewardRecorders < ActiveRecord::Migration
  def change
    create_table :system_reward_recorders, options: 'ENGINE=INNODB, CHARSET=UTF8' do |t|
      t.string :system_message
      t.string :reward_type
      t.integer :user_id
      t.integer :receive_or_not

      t.timestamps
    end
  end
end
