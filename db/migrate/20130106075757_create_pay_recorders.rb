class CreatePayRecorders < ActiveRecord::Migration
  def change
    create_table :pay_recorders, options: 'ENGINE=INNODB, CHARSET=UTF8' do |t|
      t.integer :p_type, default: -1
      t.integer :user_id, default: -1

      t.timestamps
    end
  end
end
