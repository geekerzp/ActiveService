class CreateDiscipleGongfus < ActiveRecord::Migration
  def change
    create_table :disciple_gongfus, options: 'ENGINE=INNODB, CHARSET=UTF8' do |t|
      t.integer :disciple_id, default: -1
      t.integer :gongfu_id, default: -1

      t.timestamps
    end
  end
end
