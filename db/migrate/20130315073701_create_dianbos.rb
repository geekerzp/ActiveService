class CreateDianbos < ActiveRecord::Migration
  def change
    create_table :dianbos, options: 'ENGINE=INNODB, CHARSET=UTF8' do |t|
      t.integer :type
      t.integer :number

      t.timestamps
    end
  end
end
