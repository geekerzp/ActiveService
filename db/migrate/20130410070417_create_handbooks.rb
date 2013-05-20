class CreateHandbooks < ActiveRecord::Migration
  def change
    create_table :handbooks, options: 'ENGINE=INNODB, CHARSET=UTF8' do |t|
      t.integer :object_type
      t.integer :exist_type
      t.integer :object_id
      t.integer :user_id

      t.timestamps
    end
  end
end
