class CreateAnswers < ActiveRecord::Migration
  def self.up
    create_table :answers do |t|
      t.integer :query_id
      t.integer :doc_id
      t.integer :relevance    
    end
  end

  def self.down
    drop_table :answers
  end
end
