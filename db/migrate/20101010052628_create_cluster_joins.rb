class CreateClusterJoins < ActiveRecord::Migration
  def self.up
    create_table :cluster_joins,  :id=>false do |t|
      t.integer :parent_id
      t.integer :child_id
    end
  end

  def self.down
    drop_table :cluster_joins
  end
end
