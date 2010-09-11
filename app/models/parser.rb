class Parser
  def self.parse(file_name)
    file = File.open(file_name)   
    
    regexp = /^\.([A-Z]) (\d*)|^\.([A-Z])|(^[^\.].*)/

    # $1 Existe un indice
    # $2 Numero de Indice
    # $3 Atributo
    # $4 Contenido de Atributo
   
    print "Parsing...\n"
    until file.eof? do
    #100.times do
      if file.gets =~ regexp
        
        if $1 and $2
          if @doc
            @doc.terms_definition
            @doc.save
          end  
          @doc = Doc.new     
        end
            
        if $3
          letter = $3.to_s.downcase
          case letter
            when 'a'  then  letter='author'
            when 'b'  then  letter='biblio'
            when 't'  then  letter='title'             
            when 'w'  then  letter='content'              
          end
          @temp = letter
          eval("@doc.#{@temp}=''")
        end
        
        if $4
          eval("@doc.#{@temp} +=\$4")
        end      
      end  # regexp match
    end #file.gets
    
    file.close
    @doc.terms_definition; @doc.save #Save last doc.
    Term.set_idf
    print "Parsing: Done\n"    
    true
  end
  
  
  def self.query_parse(file_name)
    file = File.open(file_name)   
    
    regexp = /^\.([A-Z]) (\d*)|^\.([A-Z])|(^[^\.].*)/

    # $1 Existe un indice
    # $2 Numero de Indice
    # $3 Atributo
    # $4 Contenido de Atributo
   
    print "Parsing...\n"
    until file.eof? do
      if file.gets =~ regexp
        
        if $1 and $2
          if @query
            @query.terms_definition
            #@query.save
          end  
          @query = Query.new(:query_id=>$2);          
        end
            
        if $3
          @query.content=''
        end
        
        if $4
          @query.content += $4
        end      
        
      end  # regexp match
    end #file.eof
    
    @query.terms_definition; #Save last doc.
    
    file.close

    print "Parsing: Done\n"      
    true
  end

end
