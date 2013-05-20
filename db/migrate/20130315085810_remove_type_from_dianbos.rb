class RemoveTypeFromDianbos < ActiveRecord::Migration
  def up
    remove_column :dianbos, :type
  end

  def down
    add_column :dianbos, :type, :integer
  end
end
