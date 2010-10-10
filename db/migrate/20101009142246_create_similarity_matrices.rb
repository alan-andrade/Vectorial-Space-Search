class CreateSimilarityMatrices < ActiveRecord::Migration
  def self.up
    create_table :similarity_matrices, :id=>false do |t|
      t.integer :x
      t.integer :y
      t.float   :similarity
    end
  end

  def self.down
    drop_table :similarity_matrices
  end
end
