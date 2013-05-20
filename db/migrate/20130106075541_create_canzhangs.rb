class CreateCanzhangs < ActiveRecord::Migration
  def change
    create_table :canzhangs, options: 'ENGINE=INNODB, CHARSET=UTF8' do |t|
      t.integer :cz_type, default: -1
      t.integer :user_id, default: -1
      t.integer :number, default: 0

      t.timestamps
    end
  end
end
