class AddExperienceToGongfu < ActiveRecord::Migration
  def change
    add_column :gongfus, :experience, :integer, default: 0
  end
end
