class ChangeSoulColumns < ActiveRecord::Migration
  def up
    remove_column :souls, :disciple_id
    add_column :souls, :s_type, :string, :default => ''
  end

  def down
    remove_column :souls, :s_type
    add_column :souls, :disciple_id, :integer, :default => -1
  end
end
