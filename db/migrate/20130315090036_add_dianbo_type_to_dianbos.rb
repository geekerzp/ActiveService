class AddDianboTypeToDianbos < ActiveRecord::Migration
  def change
    add_column :dianbos, :dianbo_type, :integer
  end
end
