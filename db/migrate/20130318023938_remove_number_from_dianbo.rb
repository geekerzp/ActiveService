class RemoveNumberFromDianbo < ActiveRecord::Migration
  def up
    remove_column :dianbos, :number
  end

  def down
    add_column :dianbos, :number, :integer
  end
end
