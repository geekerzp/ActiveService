class CreateServers < ActiveRecord::Migration
  def change
    create_table :servers, options: 'ENGINE=INNODB, CHARSET=UTF8' do |t|
      t.string :name, default: ''
      t.string :address, default: '127.0.0.1'
      t.integer :state, default: 1

      t.timestamps
    end
  end
end
