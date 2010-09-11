class CreateTerms < ActiveRecord::Migration
  def self.up
    create_table :terms do |t|
      t.string  :term
      t.float :idf
    end    
  end

  def self.down
    drop_table :terms
  end
end
