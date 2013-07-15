class CreateRechargeRecorders < ActiveRecord::Migration
  def change
    create_table :recharge_recorders do |t|
      t.references :user
      t.integer :gold, :null => false, :default => 0    # 充值的元宝数
      t.integer :silver, :null => false, :default => 0  # 充值的银两数

      t.timestamps
    end
  end
end
