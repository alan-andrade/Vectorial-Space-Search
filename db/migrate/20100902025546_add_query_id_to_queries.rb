class AddQueryIdToQueries < ActiveRecord::Migration
  def self.up
    add_column :queries, :query_id, :integer
  end

  def self.down
    remove_column :queries, :query_id
  end
end
