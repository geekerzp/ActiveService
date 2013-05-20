class CreateCanbaiRewardRecorders < ActiveRecord::Migration
  def change
    create_table :canbai_reward_recorders, options: 'ENGINE=INNODB, CHARSET=UTF8'  do |t|
      t.integer :r_type, default: 3
      t.integer :user_id
      t.integer :accumulated_continuous_time, default: 0
      t.date :last_canbai_time, default: '1900-1-1'

      t.timestamps
    end
  end
end
