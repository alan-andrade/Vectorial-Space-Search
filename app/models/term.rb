class Term < ActiveRecord::Base
  has_many  :doc_terms
  has_many  :docs,     :through=>:doc_terms
  has_many  :queries
  
  def self.set_idf    
    connection.execute('replace into terms (id, term, idf) select term_id, t.term, log((select count(*) from docs) / count(*)) gidf from doc_terms dt, terms t where dt.term_id = t.id group by term_id')    
    true
  end  
end
