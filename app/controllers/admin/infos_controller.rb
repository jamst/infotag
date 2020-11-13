class Admin::InfosController < Admin::BaseController

  before_action :set_info, only: [:destroy,:edit,:show,:update,:update_status,:to_approve,:update_approve]
  skip_before_action :verify_authenticity_token

  def index
    @q = SearchParams.new(params[:search_params] || {approve_status: :wapprove})
    @infos = Info.default_where(@q.attributes(self)).order(:approve_status,id: :desc).page(params[:page]).per(100)
  end

  # 已审核资讯列表
  def approved_list
    @q = SearchParams.new(params[:search_params] || {})
    @infos = Info.approved.default_where(@q.attributes(self)).order(updated_at: :desc).page(params[:page]).per(100)
  end

  # 审核状态
  def to_approve
    
  end
  def update_approve
    @info.update_attributes(permitted_resource_params)
  end


  # 批量更新
  def to_approves
    @inquiry_ids = params[:inquiry_ids]
    @info =  Info.new
  end
  def update_approves
    Info.where(id:params[:inquiry_ids].to_s.split(",")).each do |info|
      info.update_attributes(permitted_resource_params)
    end
  end
  
  # 批量删除
  def be_deletes
    Info.where(id:params[:inquiry_ids].to_s.split(",")).each do |info|
      info.srem_tag_list
      info.update(is_delete: Time.now.to_i)
    end
  end

  # 更新今日推荐
  def uptoday
    Info.add_today_list
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
    @info.srem_tag_list
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
    if params[:status] == "enabled"
      @info.tag_list
    else
      @info.srem_tag_list
    end
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
