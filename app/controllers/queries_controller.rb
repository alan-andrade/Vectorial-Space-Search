class QueriesController < ApplicationController
layout  'docs'

  def create
    if  Parser.parse(params[:queries], :query)      
      flash[:notice]  = 'Success parsing queries'
      QueryWeight.fill
    else
      flash[:notice]  = 'FAIL!'
    end
  end
  
  def search
    ## El usuario emite una consulta. @query_id(tabla que traera todos los terminos del query).
    
    @query_id     = params[:query_id]
    @metodo       = params[:metodo]    
    @query_terms  = Query.find_all_by_query_id(@query_id).map{|q| q.term.term } # parlabras de la consulta
    @results      = Query.query(@query_id, @metodo)
    
    ## El usuario selecciona un conjunto R de n1 de documentos relevantes.
    
    @answers          = Answer.find_all_by_query_id(@query_id)
    @relevant_doc_ids = @answers.map{|ans| ans.doc_id.to_s} #Array of Relevant Docs.
    results_ids       = @results.map{|doc| doc.id}    
    n1                = results_ids.size
    
    ## Quedando una lista de irrelevantes n2.
    
    irrelevantes  = results_ids - @relevant_doc_ids
    n2            = irrelevantes.size
    
    ## Se suman los vectores de los documentos relevantes.
    vector_suma_docs_relevantes = Doc.find(@relevant_doc_ids).map{|doc| doc.terms.map{|term| term.term} }
    
    
  end

end
