class Admin::ClassificationsController < Admin::BaseController

  before_action :set_classification, only: [:destroy,:edit,:show,:update,:update_status]
  skip_before_action :verify_authenticity_token

  def index
    @q = SearchParams.new(params[:search_params] || {})
    @classifications = Classification.default_where(@q.attributes(self)).order(:name).page(params[:page]).per(50)
  end

  def new
    @classification =  Classification.new
    render :layout => false
  end

  def edit
    render :layout => false
  end

  def show
    render :layout => false
  end


  def update
    @classification.update_attributes(permitted_resource_params)
  end

  def create
    @classification = Classification.new
    @classification.attributes = permitted_resource_params
    if @classification.save
      respond_with(@classification) do |format|
        format.html { redirect_to location_after_save }
        format.js   { render :layout => false }
      end
    else
      respond_with(@classification) do |format|
        format.html do
          flash.now[:error] = @classification.errors.full_messages.join(", ")
          render action: 'new'
        end
        format.js { render layout: false }
      end
    end
  end

  def destroy
    @classification.is_delete = Time.now.to_i
    if @classification.save
      respond_to do |format|
        format.js
      end
    else
      respond_with(@classification) do |format|
        format.html { redirect_to location_after_destroy }
      end
    end
  end

  # 更新状态
  def update_status
     @classification.update(status:params[:status])
  end


  private

  def set_classification
    @classification = Classification.find(params[:id])
  end

  def permitted_resource_params
    params.require(:classification).permit!
  end



end
