class ChangeTypeIntToStringFromOrders < ActiveRecord::Migration
  def up
    change_column(:orders, :type, :string)    # 修改orders表的type列为string类型
  end

  def down
  end
end
