class AddIsopenToGiftbagPurchaseRecorder < ActiveRecord::Migration
  def change
    add_column :giftbag_purchase_recorders, :is_open, :boolean, default: false
  end
end
