class CreateQueryWeights < ActiveRecord::Migration
  def self.up
    create_table :query_weights do |t|
      t.float :weight
    end
  end

  def self.down
    drop_table :query_weights
  end
end
