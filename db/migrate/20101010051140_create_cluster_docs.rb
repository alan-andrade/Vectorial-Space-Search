class CreateClusterDocs < ActiveRecord::Migration
  def self.up
    create_table :cluster_docs, :id =>  false do |t|
      t.integer :cluster_id
      t.integer :doc_id
    end
  end

  def self.down
    drop_table :cluster_docs
  end
end
