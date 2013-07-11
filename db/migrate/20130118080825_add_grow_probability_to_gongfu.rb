class AddGrowProbabilityToGongfu < ActiveRecord::Migration
  def change
    add_column :gongfus, :grow_probability, :float
  end
end
