class Term < ActiveRecord::Base
  has_many :doc_terms
  has_many :docs,     :through=>:doc_terms
  has_many :queries
  
  def self.set_idf
    n = Doc.count.to_f
    all.each do |t|      
      t.idf = Math::log10(n / (t.docs | t.queries).count.to_f )
      print t.term.to_s + " - " + t.idf.to_s + "\n"
      t.save
    end   #each term
    true
  end  
end
