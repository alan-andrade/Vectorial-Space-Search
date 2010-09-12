require 'stemmable'

class CommonActionsObject < ActiveRecord::Base
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
            
  @@existing_terms_array = []
  attr_accessor :temporal_section  
  
            
  def start_section(section_letter)
    section_letter    =   section_letter.to_s.downcase
    self.temporal_section  =   SECTIONS[section_letter]
    eval("self.#{temporal_section}=''")
  end
  
  def add_to_section(file_content)
    file_content  = file_content.to_s
    eval("self.#{self.temporal_section} << file_content")
  end    
  
  def terms_definition #Define Terms
    temporal_terms_array = Array.new
    temporal_terms_array << content.to_s.gsub(/\W+/, ' ').split(' ').map{|w| w.to_s.stem }  #Aplicamos reglas Porter Stemmer
    temporal_terms_array.flatten!                                                           #We push words, not Term objects    
    temporal_terms_array.reject! { |term| STOP_WORDS.include?(term) }                       #Quitamos Stop Words.
    @@existing_terms_array  <<  temporal_terms_array.uniq
    @@existing_terms_array.flatten!.uniq!
        
    until temporal_terms_array.empty? do
      temporal_terms_array.each do |temporal_term|
        tf                      =   temporal_terms_array.find_all{|term|  term  ==  temporal_term}.size
        existent_term           =   @@existing_terms_array.find{|term|    term  ==  temporal_term}       # Ya existe el termino? 
        existent_term           =   Term.find_by_term(existent_term) unless existent_term.nil?
        if self.class == Doc
          DocTerm.create( :term=> existent_term.nil? ? Term.new(:term=>temporal_term) : existent_term,  :tf=> tf, :doc => self)                                   
        else
          Query.create(   :term=> existent_term.nil? ? Term.new(:term=>temporal_term) : existent_term,  :tf=> tf, :query_id => query_id)
        end
        temporal_terms_array.delete_if {|term| term == temporal_term }  # We counted the term with his tf, get it out of the ARRAY!        
      end #each
     end #until
  end #def 
end
