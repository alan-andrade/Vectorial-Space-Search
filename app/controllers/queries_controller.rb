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

end

