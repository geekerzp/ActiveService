class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.string :csid                                                           # 消费流水号
      t.string :oid, :unique => true                                          # 订单号
      t.integer :gid, :default => 0                                           # 商品id
      t.integer :user_id                                                      # 用户id
      t.string :ginfo, :default => nil                                        # 商品信息
      t.integer :gcount, :default => 0                                        # 商品数量
      t.decimal :ogmoney, :default => 0, :precision => 8, :scale => 2         # 原始总价
      t.decimal :omoney, :default => 0, :precision => 8,  :scale => 2         # 实际总价
      t.integer :type, :default => nil                                       # 商品类型
      t.integer :status, :default => 0                                        # 0: 未处理， 1：成功， 2：失败

      t.timestamps
    end
  end
end
