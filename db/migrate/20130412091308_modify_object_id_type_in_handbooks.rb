class ModifyObjectIdTypeInHandbooks < ActiveRecord::Migration
  def up
    change_column :handbooks, :object_id, :string
  end

  def down
    change_column :handbooks, :object_id, :integer
  end
end
