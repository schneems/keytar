class CreateBars < ActiveRecord::Migration
  def self.up
    create_table :bars do |t|
      t.column :name, :string, :null => false
    end
  end

  def self.down
    drop_table :bars
  end
end
