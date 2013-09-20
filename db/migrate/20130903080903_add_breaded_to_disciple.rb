class AddBreadedToDisciple < ActiveRecord::Migration
  def change
    add_column :disciples, :breaked_token, :string
  end
end
