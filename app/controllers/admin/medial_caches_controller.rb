class Admin::MedialCachesController < Admin::BaseController

  before_action :set_medial_cache, only: [:destroy,:edit,:show,:update,:update_status]
  skip_before_action :verify_authenticity_token

  def index
    @q = SearchParams.new(params[:search_params] || {})
    @medial_caches = MedialCache.default_where(@q.attributes(self)).order(created_at: :desc).page(params[:page]).per(10)
  end


  def edit
    render :layout => false
  end

  def show
    render :layout => false
  end


  def update
    @medial_cache.update_attributes(permitted_resource_params)
  end


  def destroy
    @medial_cache.is_delete = Time.now.to_i
    if @medial_cache.save
      respond_to do |format|
        format.js
      end
    else
      respond_with(@medial_cache) do |format|
        format.html { redirect_to location_after_destroy }
      end
    end
  end


  # 更新状态
  def update_status
    @medial_cache.update(status:params[:status])
  end


  private

  def set_medial_cache
    @medial_cache = MedialCache.find(params[:id])
  end

  def permitted_resource_params
    params.require(:medial_cache).permit!
  end


end
