class Doc < CommonActionsObject
  set_table_name :docs

  has_many :doc_terms
  has_many :terms, :through => :doc_terms
  after_save :terms_definition  
  
  def self.most_important_term(id)
    find_by_sql("SELECT d.term_id term_id, t.term term, max(d.tf*t.idf) weight FROM doc_terms d, terms t where doc_id=#{id} AND t.id = d.term_id").first
  end 

end
