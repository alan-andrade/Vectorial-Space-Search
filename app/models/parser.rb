class Parser
  def self.parse(file_name, class_name)
    raise 'NoArgumentGiven' if class_name.nil?
    class_name = class_name.to_s.capitalize
    file = File.open(file_name)   
    
    regexp = /^\.([A-Z]) (\d*)|^\.([A-Z])|(^[^\.].*)/    

    # $1 Existe un indice
    # $2 Numero de Indice
    # $3 Atributo
    # $4 Contenido de Atributo
   
    print "Parsing...\n"
    obj = nil
    initialize_code = if    class_name  ==  'Doc'
                         "#{class_name}.new"
                      elsif class_name  == 'Query'
                          "#{class_name}.new(:query_id=>$2)"
                      end
    save_query_code = (class_name == 'Query' ? "obj.save_query" : "obj.save")
                      
    until file.eof? do
      if file.gets =~ regexp
        if $1 and $2  # Detectamos la primera parte del archivo. Es la letra I, y su ID.
          if obj.nil?            
            obj = eval(initialize_code)
          else
            eval(save_query_code)
            obj = eval(initialize_code)
          end          
        elsif $3      # Encontramos una seccion
          obj.start_section($3)
        elsif $4      # Encontramos contenido de una seccion.
          obj.add_to_section($4)          
        end            
      end   # regexp match
    end     # file.gets        
    file.close       
    eval(save_query_code)
    
    print "Parsing: Done\n"    
    true
  end
end
