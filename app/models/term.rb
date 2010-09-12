class Term < ActiveRecord::Base
  has_many :doc_terms
  has_many :docs,     :through=>:doc_terms
  has_many :queries
  
  def self.set_idf    
    find_by_sql("select term_id ,log((select count(*) from docs) / count(*)) idf from doc_terms group by term_id").each do |term|
     Term.find(term.term_id).update_attribute 'idf', term.idf
    end
    true
  end  
end
