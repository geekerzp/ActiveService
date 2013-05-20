class CreateLunjianPositions < ActiveRecord::Migration
  def change
    create_table :lunjian_positions, options: 'ENGINE=INNODB, CHARSET=UTF8' do |t|
      t.integer :user_id, default: -1
      t.integer :position, default: 2**31 - 1
      t.integer :score, default: 0
      t.integer :left_time, default: 0

      t.timestamps
    end
  end
end
