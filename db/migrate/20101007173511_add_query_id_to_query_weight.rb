class AddQueryIdToQueryWeight < ActiveRecord::Migration
  def self.up
    add_column :query_weights, :query_id, :integer
  end

  def self.down
    remove_column :query_weights, :query_id
  end
end
