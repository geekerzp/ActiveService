class CreateUserGoods < ActiveRecord::Migration
  def change
    create_table :user_goods, options: 'ENGINE=INNODB, CHARSET=UTF8' do |t|
      t.integer :g_type, default: -1
      t.integer :user_id, default: -1
      t.integer :number, default: 0

      t.timestamps
    end
  end
end
