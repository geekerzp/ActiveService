class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages, options: 'ENGINE=INNODB, CHARSET=UTF8' do |t|
      t.integer :sender_id
      t.integer :receiver_id
      t.string :message

      t.timestamps
    end
  end
end
