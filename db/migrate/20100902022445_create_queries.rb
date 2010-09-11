class CreateQueries < ActiveRecord::Migration
  def self.up
    create_table :queries do |t|
      t.integer :term_id
      t.integer :tf
    end
  end

  def self.down
    drop_table :queries
  end
end
