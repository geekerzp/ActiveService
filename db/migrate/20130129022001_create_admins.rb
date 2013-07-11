class CreateAdmins < ActiveRecord::Migration
  def change
    create_table :admins, options: 'ENGINE=INNODB, CHARSET=UTF8' do |t|
      t.string :username
      t.string :password

      t.timestamps
    end
  end
end
