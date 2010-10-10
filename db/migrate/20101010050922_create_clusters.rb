class CreateClusters < ActiveRecord::Migration
  def self.up
    create_table :clusters do |t|
      t.float :centroid
    end
  end

  def self.down
    drop_table :clusters
  end
end
