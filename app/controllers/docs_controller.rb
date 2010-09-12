class DocsController < ApplicationController

  def index
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def create
   
    file_name = params[:collection]

    respond_to do |format|
      if Parser.parse(file_name, :doc)
        flash[:notice] = 'Doc was successfully created. Calculating IDF'
        Term.set_idf        
        format.html { redirect_to(root_path) }
      else
        format.html { render :action => "new" }
      end
    end
  end
  
  def show
    @doc  = Doc.find(params[:id])
  end

end
