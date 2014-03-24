class ContentController < ApplicationController
  def index
  	@contents = Content.paginate(:page => params[:page], :per_page => 10, :order => 'created_at DESC')  
  end

  def view
  	@content = Content.find(params[:id])
  end
end
