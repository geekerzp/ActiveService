class CreateJiaohuajiRecorders < ActiveRecord::Migration
  def change
    create_table :jiaohuaji_recorders, options: 'ENGINE=INNODB, CHARSET=UTF8' do |t|
      t.integer :type
      t.integer :user_id

      t.timestamps
    end
  end
end
