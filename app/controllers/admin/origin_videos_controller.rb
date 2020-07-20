class Admin::OriginVideosController < Admin::BaseController

  before_action :set_origin_video, only: [:destroy,:edit,:show,:update,:update_status]

  def index
    @q = SearchParams.new(params[:search_params] || {})
    @videos = SpiderOriginVideo.default_where(@q.attributes(self)).page(params[:page]).per(10)
  end

  def new
    @video =  SpiderOriginVideo.new
    render :layout => false
  end

  def edit
    render :layout => false
  end

  def show
    render :layout => false
  end


  def update
    @video.update_attributes(permitted_resource_params)
  end

  def create
    @video = SpiderOriginVideo.new
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
     @video.update(status:params[:status])
  end


  private

  def set_origin_video
    @video = SpiderOriginVideo.find(params[:id])
  end

  def permitted_resource_params
    params.require(:origin_video).permit!
  end



end
