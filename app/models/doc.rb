class Doc < CommonActionsObject
  set_table_name :docs

  has_many :doc_terms
  has_many :terms, :through => :doc_terms
  after_save :terms_definition  
  
end
