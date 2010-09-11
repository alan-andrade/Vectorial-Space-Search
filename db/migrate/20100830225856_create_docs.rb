class CreateDocs < ActiveRecord::Migration
  def self.up
    create_table :docs do |t|
      t.string :author
      t.string :title
      t.string :biblio
      t.string :excerpt
      t.text :content
    end
  end

  def self.down
    drop_table :docs
  end
end
