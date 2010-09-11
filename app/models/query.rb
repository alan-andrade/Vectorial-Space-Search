require 'stemmable'

class Query < ActiveRecord::Base
  attr_accessor :content
  belongs_to  :term 
  
  STOP_WORDS = %w[
    a b c d e f g h i j k l m n o p q r s t u v w x y z
    an and are as at be by for from has he in is it its
    of on that the to was were will with upon without among
  ]  
  
  def terms_definition #Define Terms    
    t_terms = Array.new << content.to_s.gsub(/\W+/, ' ').split(' ').map{|w| w.to_s.stem }; t_terms.flatten!
    print t_terms.to_s + "\n\n"
    t_terms.reject! { |term| STOP_WORDS.include?(term) }
    print t_terms.to_s + "\n\n"
    until t_terms.empty? do
      t_terms.each do |term|
        @termi = term
        tf = t_terms.find_all{|t| t == @termi}.size
        existent_term = Term.find_by_term(term) # Already Exists the term?
        Query.create(:term=> existent_term.nil? ? Term.new(:term=>term) : existent_term , :tf=> tf, :query_id => query_id)
        t_terms.delete_if {|term| term == @termi }  # We counted the term with his tf, get it out of the ARRAY! 
        print "Quedo asi: " + t_terms.to_s + "\n\n"
      end
    end
  end
  
  def self.query(queryid=1)
    find_by_sql("select i.doc_id docid, sum(q.tf * t.idf * i.tf * t.idf) weight from queries q, doc_terms i, terms t where q.query_id = #{queryid} AND q.term_id = t.id AND i.term_id = t.id group by i.doc_id order by 2 desc")
  end
end
