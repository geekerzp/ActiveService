class CreateCanbaiRecorders < ActiveRecord::Migration
  def change
    create_table :canbai_recorders, options: 'ENGINE=INNODB, CHARSET=UTF8'  do |t|
      t.integer :user_id
      t.datetime :canbai_at

      t.timestamps
    end
  end
end
