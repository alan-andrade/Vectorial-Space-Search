class SearchesController < ApplicationController
layout  'docs'

  def create
    @query_id     = params[:query_id]
    @metodo       = params[:metodo]  
    @iterations   = params[:iterations]

    # We get the relevant documents from the Answers table.
    
    @answers          = Answer.find_all_by_query_id(@query_id)
    @relevant_doc_ids = @answers.map{|ans| ans.doc_id.to_s}      

    if params[:feedback]  # User wants Relevance Feedback ?         
      @results = Query.query_with_feedback(@query_id, @iterations, @metodo)     
    else                  # No feedback? Make the Normal Query!   
      @results = Query.query(@query_id, @metodo)          
    end
    
    if params[:clustering]
      
    end
    
    render :action => :show
  end
  
  def show
  end
  
end
