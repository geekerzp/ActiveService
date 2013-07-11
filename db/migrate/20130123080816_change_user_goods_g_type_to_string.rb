class ChangeUserGoodsGTypeToString < ActiveRecord::Migration
  def up
    change_column :user_goods, :g_type, :string
  end

  def down
    change_column :user_goods, :g_type, :integer
  end
end
