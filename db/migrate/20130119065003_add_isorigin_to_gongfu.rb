class AddIsoriginToGongfu < ActiveRecord::Migration
  def change
    add_column :gongfus, :is_origin, :boolean
  end
end
