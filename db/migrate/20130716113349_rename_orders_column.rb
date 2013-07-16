class RenameOrdersColumn < ActiveRecord::Migration
  def up
  	rename_column :orders, :type, :o_type
  end

  def down
  end
end
