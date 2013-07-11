class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users, options: 'ENGINE=INNODB, CHARSET=UTF8' do |t|
      t.string :username
      t.string :password

      t.string :name, default: ''

      t.integer :vip_level, default: 1
      t.integer :level, default: 1
      t.integer :prestige, default: 0
      t.integer :gold, default: 0
      t.integer :silver, default: 0
      t.integer :power, default: 0
      t.integer :experience, default: 0
      t.integer :sprite, default: 0

      t.string :last_login_ip
      t.datetime :last_login_time


      t.timestamps
    end
  end
end
