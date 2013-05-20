class ChangeCzTypeToString < ActiveRecord::Migration
  def up
    change_column :canzhangs, :cz_type, :string
  end

  def down
    change_column :canzhangs, :cz_type, :integer
  end
end
