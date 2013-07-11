class AddBreaktimeToDisciple < ActiveRecord::Migration
  def change
    add_column :disciples, :break_time, :integer, :default => 0
  end
end
