class CreateDocTerms < ActiveRecord::Migration
  def self.up
    create_table :doc_terms, :id=>false do |t|
      t.integer :doc_id
      t.integer :term_id
      t.integer :tf
    end
  end

  def self.down
    drop_table :doc_terms
  end
end
