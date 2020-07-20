class Admin::InfosController < Admin::BaseController

  before_action :set_info, only: [:destroy,:edit,:show,:update,:update_status,:to_approve,:update_approve]

  def index
    @q = SearchParams.new(params[:search_params] || {})
    @infos = Info.default_where(@q.attributes(self)).page(params[:page]).per(10)
  end

  # 已审核资讯列表
  def approved_list
    @q = SearchParams.new(params[:search_params] || {})
    @infos = Info.approved.default_where(@q.attributes(self)).page(params[:page]).per(10)
  end

  # 审核状态
  def to_approve
    
  end
  def update_approve
    @info.update_attributes(permitted_resource_params)
  end

  def new
    @info =  Info.new
    render :layout => false
  end

  def edit
    render :layout => false
  end

  def show
    render :layout => false
  end


  def update
    @info.update_attributes(permitted_resource_params)
  end

  def create
    @info = Info.new
    @info.attributes = permitted_resource_params
    if @info.save
      respond_with(@info) do |format|
        format.html { redirect_to location_after_save }
        format.js   { render :layout => false }
      end
    else
      respond_with(@info) do |format|
        format.html do
          flash.now[:error] = @info.errors.full_messages.join(", ")
          render action: 'new'
        end
        format.js { render layout: false }
      end
    end
  end

  def destroy
    @info.is_delete = Time.now.to_i
    if @info.save
      respond_to do |format|
        format.js
      end
    else
      respond_with(@info) do |format|
        format.html { redirect_to location_after_destroy }
      end
    end
  end

  # 更新状态
  def update_status
     @info.update(status:params[:status])
  end


  private

  def set_info
    @info = Info.find(params[:id])
  end

  def permitted_resource_params
    params.require(:info).permit!
  end



end
