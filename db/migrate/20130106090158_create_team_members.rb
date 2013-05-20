class CreateTeamMembers < ActiveRecord::Migration
  def change
    create_table :team_members, options: 'ENGINE=INNODB, CHARSET=UTF8' do |t|
      t.integer :user_id, default: -1
      t.integer :disciple_id, default: -1
      t.integer :position, default: -1

      t.timestamps
    end
  end
end
