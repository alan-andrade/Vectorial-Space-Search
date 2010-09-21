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
    @query_id     = params[:query_id]
    @metodo       = params[:metodo]
    @query_terms  = Query.find_all_by_query_id(@query_id).map{|q| q.term.term } # parlabras de la consulta
    @results      = Query.query(@query_id, @metodo)
    @answers      = Answer.find_all_by_query_id(@query_id)
    @relevant_doc_ids      = @answers.map{|ans| ans.doc_id.to_s} #Array of Relevant Docs.
    
  end

end
