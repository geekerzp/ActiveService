class ChangeTypeToString < ActiveRecord::Migration
  def up
    change_column :gongfus, :gf_type, :string, :default => ''
    change_column :disciples, :d_type, :string, :default => ''
    change_column :equipment, :e_type, :string, :default => ''
  end

  def down
    change_column :gongfus, :gf_type, :integer, :default => -1
    change_column :disciples, :d_type, :integer, :default => -1
    change_column :equipment, :e_type, :integer, :default => -1
  end
end
