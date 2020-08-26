class Admin::TagsController < Admin::BaseController

  before_action :set_tag, only: [:destroy,:edit,:show,:update,:update_status]
  skip_before_action :verify_authenticity_token

  def index
    @q = SearchParams.new(params[:search_params] || {})
    @tags = Tag.default_where(@q.attributes(self)).page(params[:page]).per(10)
  end

  def new
    @tag =  Tag.new
    render :layout => false
  end

  def edit
    @tag.connection_tags = @tag.connection_tags&.join(",")
    render :layout => false
  end

  def show
    render :layout => false
  end


  def update
    @tag.update_attributes(permitted_resource_params)
  end

  def create
    @tag = Tag.new
    @tag.attributes = permitted_resource_params
    if @tag.save
      respond_with(@tag) do |format|
        format.html { redirect_to location_after_save }
        format.js   { render :layout => false }
      end
    else
      respond_with(@tag) do |format|
        format.html do
          flash.now[:error] = @tag.errors.full_messages.join(", ")
          render action: 'new'
        end
        format.js { render layout: false }
      end
    end
  end

  def destroy
    @tag.srem_tag_list
    @tag.is_delete = Time.now.to_i
    if @tag.save
      respond_to do |format|
        format.js
      end
    else
      respond_with(@tag) do |format|
        format.html { redirect_to location_after_destroy }
      end
    end
  end

  # 更新状态
  def update_status
     @tag.update(status:params[:status])
  end


  private

  def set_tag
    @tag = Tag.find(params[:id])
  end

  def permitted_resource_params
    params.require(:tag).permit!
  end


end
