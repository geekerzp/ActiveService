class CreateCanzhangGrabRecorders < ActiveRecord::Migration
  def change
    create_table :canzhang_grab_recorders, options: 'ENGINE=INNODB, CHARSET=UTF8' do |t|
      t.integer :attacker_id
      t.integer :defender_id
      t.integer :who_win
      t.string  :cz_type

      t.timestamps
    end
  end
end
