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
    @results = Query.query(@query_id, @metodo)      
    
    # Se recaba la informacion de los documentos relevantes en @answers. Se obtienen los ids de los documentos que resultaron.
    @answers          = Answer.find_all_by_query_id(@query_id)
    @relevant_doc_ids = @answers.map{|ans| ans.doc_id.to_s} #Array of Relevant Docs.    
    
    # If que permite usar o no relevancia dependiendo de la decision del usuario.
    if params[:feedback]      
      @results = Query.query_with_feedback(@query_id, @metodo, @results, @relevant_doc_ids, query_terms_ids, @query_terms)        
    end #end if feedback   
    
  end

end

