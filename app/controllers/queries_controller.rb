class QueriesController < ApplicationController
layout  'docs'
  def create
    if  Parser.query_parse(params[:queries])
      flash[:notice]  = 'Success parsing queries'
    else
      flash[:notice]  = 'FAIL!'
    end
    redirect_to root_path #dummy
  end
  
  def search
    @query_id = params[:query_id]
    @query_terms  = Query.find_all_by_query_id(@query_id).map{|q| q.term.term }
    @results  = Query.query(@query_id)
    @answers  = Answer.find_all_by_query_id(@query_id)
    @doc_ids  = @answers.map{|ans| ans.doc_id.to_s}
    
  end

end
