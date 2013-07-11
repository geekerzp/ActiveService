class CreateRelationships < ActiveRecord::Migration
  def change
    create_table :relationships, options: 'ENGINE=INNODB, CHARSET=UTF8' do |t|
      t.integer :user_id
      t.integer :friend_id
      t.integer :relation_type

      t.timestamps
    end
  end
end
