class CreateFriendApplyRecorders < ActiveRecord::Migration
  def change
    create_table :friend_apply_recorders, options: 'ENGINE=INNODB, CHARSET=UTF8' do |t|
      t.integer :applicant_id
      t.integer :receiver_id
      t.integer :status

      t.timestamps
    end
  end
end
