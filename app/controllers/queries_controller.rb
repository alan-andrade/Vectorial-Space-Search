class QueriesController < ApplicationController
layout  'docs'

  def create
    if  Parser.parse(params[:queries], :query)      
      flash[:notice]  = 'Success parsing queries'      
      QueryWeight.fill
      redirect_to root_path
    else
      flash[:notice]  = 'FAIL!'
      redirect_to root_path
    end
  end
  
  def search
    # Se selecciona el query_id para sacar los terminos de la DB. Se obtiene un resultado.
    
    @query_id     = params[:query_id]
    @metodo       = params[:metodo]    
    @query_terms  = Query.find_all_by_query_id(@query_id).map{|q| q.term } # palabras de la consulta
    query_terms_ids = @query_terms.map(&:id)
    @query_terms  = @query_terms.map(&:term)
    @results      = Query.query(@query_id, @metodo)
    
    # Se recaba la informacion de los documentos relevantes en @answers. Se obtienen los ids de los documentos que resultaron.
    
    @answers          = Answer.find_all_by_query_id(@query_id)
    @relevant_doc_ids = @answers.map{|ans| ans.doc_id.to_s} #Array of Relevant Docs.
    results_ids       = @results.map{|doc| doc.docid}    
    
    # If que permite usar o no relevancia dependiendo de la decision del usuario.
    if params[:feedback]
      # Cuales son los ids relevantes y cuales no.
      relevantes    = []
      for result in @results
        relevantes.push result.docid if @relevant_doc_ids.include?(result.docid)
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
      @query_terms = @query_terms + (relevant_terms  - irrelevant_terms)
      total_terms_id  = query_terms_ids + relevant_terms_ids  - irrelevant_terms_ids
      
      # Arreglos temporales para agregar los terminos a la tabla queries.
      temporal_terms_ids  , temporal_created_terms  =   {}  , []    
      
      # Se recorre el arreglo de terminos y se actualiza lo necesario en la tabla Queries para poder hacer la consulta de nuevo.
      until total_terms_id.empty?        
        for termid in total_terms_id   
          p total_terms_id      
          tf = total_terms_id.count(termid)
          queryterm   = Query.find_by_query_id_and_term_id(@query_id, termid)          
          if queryterm.nil?
            queryterm = Query.create(:query_id=>@query_id, :tf => tf, :term_id => termid)
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
      @results  = Query.query(@query_id, @metodo)
      
      # Se remueven los terminos agregados temporalmente despues de tener los resultados deseados.
      temporal_terms_ids.each_pair do |id, tf|
        Query.find_by_query_id_and_term_id(@query_id, id.to_s).update_attribute 'tf', tf
      end
      for query in temporal_created_terms
        query.delete
      end
    end #end if feedback   
    
  end

end
