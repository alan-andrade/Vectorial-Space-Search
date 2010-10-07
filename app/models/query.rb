class Query < CommonActionsObject
  set_table_name :queries
  attr_accessor :content
  belongs_to    :term
  
  #METHODS = ['point_product', 'coseno']
  METHODS = {:point_product=>'Point Product', :coseno => "Coseno"}
  
  def save_query
    terms_definition
  end
    
  def self.query(query_id=1, metodo)
    # Since we render in our views the methods available in METHODS.
    self.send metodo, query_id
  end  
  
  def self.query_with_feedback(query_id=1,iterations=1,metodo)    
      # TODO: Una mejor manera de resolver este problema de elegancia.
      
      query_terms  = Query.find_all_by_query_id(query_id).map{|q| q.term } # palabras de la consulta
      query_terms_ids = query_terms.map(&:id)
      query_terms  = query_terms.map(&:term)   
      results = Query.query(query_id, metodo)      
      
      # Se recaba la informacion de los documentos relevantes en @answers. Se obtienen los ids de los documentos que resultaron.
      answers          = Answer.find_all_by_query_id(query_id)
      relevant_doc_ids = answers.map{|ans| ans.doc_id.to_s}
      results_ids      = results[:list].map{|doc| doc.docid} 
    
      # Arreglos temporales para agregar los terminos a la tabla queries.
      temporal_terms_ids  , temporal_created_terms  =   {}  , []    
      relevantes    = []
      
      iterations.to_i.times do  
      
         #TODO: Refactoring for a  cleaner and more self explainable code. 
        results[:list].each do |result|      
          relevantes.push result.docid if relevant_doc_ids.include?(result.docid)
          break if relevantes.size==5
        end
        
        irrelevantes  = (results_ids - relevantes)[0..5]
        
        # Terminos que se agregaran, se usa el arreglo de IDS 'relevantes'
        relevant_terms_array  = Doc.find(relevantes).map{|doc| Doc.most_important_term(doc.id) }   
        relevant_terms        = relevant_terms_array.map{|rt| rt.term.stem }
        relevant_terms_ids    = relevant_terms_array.map{|rt| rt.term_id.to_i}
        
        # Terminos que se Restaran, se usa el arreglo de IDS 'irrelevantes'
        irrelevant_terms_array  = Doc.find(irrelevantes).map{|doc| Doc.most_important_term(doc.id)}
        irrelevant_terms        = irrelevant_terms_array.map{|it| it.term.stem}
        irrelevant_terms_ids    = irrelevant_terms_array.map{|it| it.term_id.to_i}
        p "relevant terms: #{relevant_terms}"
        p "irrelevant terms: #{irrelevant_terms}"
        query_terms = query_terms + (relevant_terms  - irrelevant_terms)
        
        total_terms_id  = query_terms_ids + relevant_terms_ids  - irrelevant_terms_ids
        
        
        # Se recorre el arreglo de terminos y se actualiza lo necesario en la tabla Queries para poder hacer la consulta de nuevo.
        until total_terms_id.empty?        
          for termid in total_terms_id   
            p total_terms_id      
            tf = total_terms_id.count(termid)
            queryterm   = Query.find_by_query_id_and_term_id(query_id, termid)          
            if queryterm.nil?
              queryterm = Query.create(:query_id=>query_id, :tf => tf, :term_id => termid)
              temporal_created_terms.push queryterm
            elsif queryterm.tf < tf
              temporal_terms_ids[termid.to_s.to_sym]=queryterm.tf
              queryterm.update_attribute 'tf', tf
            end
            total_terms_id.delete(termid)
          end
        end
        
        # Se realiza la consulta nuevamente.
        p 'Making new Query'
        results[:list]  = Query.query(query_id, metodo)
        
      end      #end iterator
      
      # Se remueven los terminos agregados temporalmente despues de tener los resultados deseados.
      temporal_terms_ids.each_pair do |id, tf|
        Query.find_by_query_id_and_term_id(query_id, id.to_s).update_attribute 'tf', tf
      end
      
      temporal_created_terms.each{|query| query.delete }
            
      { :list => results  , :query_terms  =>  query_terms }
  end
  
  private

  
  def self.point_product(query_id=1)
    list = find_by_sql(  "select 
                      i.doc_id docid, sum(q.tf * t.idf * i.tf * t.idf) weight 
                   from 
                      queries q, doc_terms i, terms t 
                   where 
                      q.query_id = #{query_id} 
                      AND 
                        q.term_id = t.id 
                      AND 
                        i.term_id = t.id 
                   group by 
                      i.doc_id order by 2 desc")
                      
    return {
      :list => list,
      :query_terms => Query.get_query_terms(query_id)
    }
  end
  
  def self.coseno(query_id=1)
    list  = find_by_sql(  "select 
                      dt.doc_id docid, sum(q.tf * t.idf * dt.tf * t.idf) / (dw.weight * qw.weight) weight
                    from 
                      queries q, doc_terms dt, terms t, docs_weights dw, query_weights qw
                    where 
                      dt.term_id   = t.id
                    AND
                      q.query_id  = #{query_id} 
                    AND
                      dw.doc_id   = dt.doc_id
                    AND
                      q.term_id   = t.id
                    group by 
                      dt.doc_id, dw.weight, qw.weight
                    order by 
                      2 desc"  )
    {:list => list, :query_terms  =>  Query.get_query_terms(query_id)}                      
  end
  
  def self.get_query_terms(query_id)
    Term.find(Query.find_all_by_query_id(query_id).map{|q| q.term_id }).map(&:term)
  end
  

end
