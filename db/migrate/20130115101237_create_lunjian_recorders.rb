class CreateLunjianRecorders < ActiveRecord::Migration
  def change
    create_table :lunjian_recorders, options: 'ENGINE=INNODB, CHARSET=UTF8' do |t|
      t.integer :attacker_id
      t.integer :defender_id
      t.integer :who_win

      t.timestamps
    end
  end
end
