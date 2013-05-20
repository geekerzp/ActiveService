class AddPositionToGongfu < ActiveRecord::Migration
  def change
    add_column :gongfus, :position, :integer, :default => -1
  end
end
