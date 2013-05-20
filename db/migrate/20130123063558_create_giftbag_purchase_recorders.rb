class CreateGiftbagPurchaseRecorders < ActiveRecord::Migration
  def change
    create_table :giftbag_purchase_recorders, options: 'ENGINE=INNODB, CHARSET=UTF8' do |t|
      t.string :name, default: ''
      t.integer :number, default: 0
      t.integer :user_id, default: -1

      t.timestamps
    end
  end
end
