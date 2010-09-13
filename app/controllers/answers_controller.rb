class AnswersController < ApplicationController
  def create
    if  Answer.fill_db(params[:answers_doc])
      redirect_to root_path
    end     
  end
end
