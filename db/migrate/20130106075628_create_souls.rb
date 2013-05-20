class CreateSouls < ActiveRecord::Migration
  def change
    create_table :souls, options: 'ENGINE=INNODB, CHARSET=UTF8' do |t|
      t.integer :user_id, default: -1
      t.integer :disciple_id, default: -1
      t.integer :potential, default: 0
      t.integer :number, default: 0

      t.timestamps
    end
  end
end
