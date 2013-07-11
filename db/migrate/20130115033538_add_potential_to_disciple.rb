class AddPotentialToDisciple < ActiveRecord::Migration
  def change
    add_column :disciples, :potential, :integer, :default => 0
  end
end
