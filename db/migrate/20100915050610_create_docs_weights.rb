class CreateDocsWeights < ActiveRecord::Migration
  def self.up
    create_table :docs_weights do |t|
      t.integer :doc_id
      t.float :weight
    end
  end

  def self.down
    drop_table :docs_weights
  end
end
