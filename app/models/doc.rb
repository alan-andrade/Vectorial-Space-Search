require 'stemmable'

class Doc < ActiveRecord::Base

  STOP_WORDS = %w[
    a b c d e f g h i j k l m n o p q r s t u v w x y z
    an and are as at be by for from has he in is it its
    of on that the to was were will with upon without among
  ] 
  
  SECTIONS  = {
              'a' =>  'author'  ,
              'b' =>  'biblio'  ,
              't' =>  'title'   ,
              'w' =>  'content'
            }

  #has_and_belongs_to_many :terms, :join_table=>'doc_terms'
  has_many :doc_terms
  has_many :terms, :through => :doc_terms
  before_save :terms_definition 
  attr_accessor :t_terms  #temp array of terms
  attr_accessor :temporal_section
  
  def start_section(section_letter)
    section_letter    =   section_letter.to_s
    temporal_section  =   SECTIONS[section_letter]
    eval("#{temporal_section}=''")
  end
  
  def add_to_section(content)
    content = content.to_s
    eval("#{temporal_section} << content")
  end
    
  private  
  
  def terms_definition #Define Terms    
    t_terms = Array.new << content.to_s.gsub(/\W+/, ' ').split(' ').map{|w| w.to_s.stem }; t_terms.flatten! #We push words, not Term objects
    t_terms.reject! { |term| STOP_WORDS.include?(term) }
    until t_terms.empty? do
      t_terms.each do |term|
        @termi = term
        tf = t_terms.find_all{|t| t == @termi}.size
        existent_term = Term.find_by_term(term) # Already Exists the term?
        DocTerm.create(:doc=>self, :term=> existent_term.nil? ? Term.new(:term=>term) : existent_term , :tf=> tf)
        t_terms.delete_if {|term| term == @termi }  # We counted the term with his tf, get it out of the ARRAY! 
      end #each
     end #until
  end #def 
end
