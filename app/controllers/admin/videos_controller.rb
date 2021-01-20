class Admin::VideosController < Admin::BaseController

  before_action :set_video, only: [:destroy,:edit,:show,:update,:update_status,:to_approve,:update_approve]
  skip_before_action :verify_authenticity_token

  def index
    @q = SearchParams.new(params[:search_params] || {approve_status: :wapprove})
    
    @videos = Video.default_where(@q.attributes(self)).order(id: :desc).page(params[:page]).per(100)
  end

  # 已审核列表
  def approved_list
    @q = SearchParams.new(params[:search_params] || {})
    @videos = Video.approved.default_where(@q.attributes(self)).order(updated_at: :desc).page(params[:page]).per(100)
  end

  # 审核状态
  def to_approve
    
  end
  def update_approve
    @video.update_attributes(permitted_resource_params)
  end

  # 批量更新
  def to_approves
    @inquiry_ids = params[:inquiry_ids]
    @video =  Video.new
  end
  def update_approves
    Video.where(id:params[:inquiry_ids].to_s.split(",")).each do |video|
      video.update_attributes(permitted_resource_params)
    end
  end

  # 批量删除
  def be_deletes
    Video.where(id:params[:inquiry_ids].to_s.split(",")).each do |video|
      video.srem_tag_list
      video.update(is_delete: Time.now.to_i)
    end
  end

  # 导出缓存本地视频
  def export_cache_videos
    report_data = Video.location_source.where("location_source_url is null").pluck(:id,:url)
    send_data Video.to_xlsx("export_cache_videos",nil,report_data), type: 'text/xls', filename: "#{Video.table_name}_#{Time.now.to_s(:db)}.xls"
  end

  # 更新今日推荐
  def uptoday
    Video.add_today_list
  end

  def new
    @video =  Video.new
    render :layout => false
  end

  def edit
    @page_type = params[:page_type]
    render :layout => false
  end

  def show
    render :layout => false
  end


  def update
    @page_type = params[:page_type]
    @video.update_attributes(permitted_resource_params)
  end

  def create
    @video = Video.new
    @video.attributes = permitted_resource_params
    if @video.save
      respond_with(@video) do |format|
        format.html { redirect_to location_after_save }
        format.js   { render :layout => false }
      end
    else
      respond_with(@video) do |format|
        format.html do
          flash.now[:error] = @video.errors.full_messages.join(", ")
          render action: 'new'
        end
        format.js { render layout: false }
      end
    end
  end

  def destroy
    @video.srem_tag_list
    @video.is_delete = Time.now.to_i
    if @video.save
      respond_to do |format|
        format.js
      end
    else
      respond_with(@video) do |format|
        format.html { redirect_to location_after_destroy }
      end
    end
  end

  # 更新状态
  def update_status
    if params[:status] == "enabled"
      @video.tag_list
    else
      @video.srem_tag_list
    end
    @video.update(status:params[:status])
  end


  private

  def set_video
    @video = Video.find(params[:id])
  end

  def permitted_resource_params
    params.require(:video).permit!
  end



end
