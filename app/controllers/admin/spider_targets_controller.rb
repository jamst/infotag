class Admin::SpiderTargetsController < Admin::BaseController

  before_action :set_spider_target, only: [:destroy,:edit,:show,:update,:update_status]

  def index
    @q = SearchParams.new(params[:search_params] || {})
    @spider_targets = SpiderTarget.default_where(@q.attributes(self)).page(params[:page]).per(10)
  end

  def new
    @spider_target =  SpiderTarget.new
    render :layout => false
  end

  def edit
    render :layout => false
  end

  def show
    render :layout => false
  end


  def update
    @spider_target.update_attributes(permitted_resource_params)
  end

  def create
    @spider_target = SpiderTarget.new
    @spider_target.attributes = permitted_resource_params
    if @spider_target.save
      respond_with(@spider_target) do |format|
        format.html { redirect_to location_after_save }
        format.js   { render :layout => false }
      end
    else
      respond_with(@spider_target) do |format|
        format.html do
          flash.now[:error] = @spider_target.errors.full_messages.join(", ")
          render action: 'new'
        end
        format.js { render layout: false }
      end
    end
  end

  def destroy
    @spider_target.is_delete = Time.now.to_i
    if @spider_target.save
      respond_to do |format|
        format.js
      end
    else
      respond_with(@spider_target) do |format|
        format.html { redirect_to location_after_destroy }
      end
    end
  end

  # 更新状态
  def update_status
     @spider_target.update(status:params[:status])
  end


  private

  def set_spider_target
    @spider_target = SpiderTarget.find(params[:id])
  end

  def permitted_resource_params
    params.require(:spider_target).permit!
  end



end
