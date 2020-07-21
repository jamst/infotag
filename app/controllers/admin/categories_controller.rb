class Admin::CategoriesController < Admin::BaseController

  before_action :set_category, only: [:destroy,:edit,:show,:update,:update_status]

  def index
    @q = SearchParams.new(params[:search_params] || {})
    @categories = Category.default_where(@q.attributes(self)).page(params[:page]).per(10)
  end

  def new
    @category =  Category.new
    render :layout => false
  end

  def edit
    render :layout => false
  end

  def show
    render :layout => false
  end


  def update
    @category.update_attributes(permitted_resource_params)
  end

  def create
    @category = Category.new
    @category.attributes = permitted_resource_params
    if @category.save
      respond_with(@category) do |format|
        format.html { redirect_to location_after_save }
        format.js   { render :layout => false }
      end
    else
      respond_with(@category) do |format|
        format.html do
          flash.now[:error] = @category.errors.full_messages.join(", ")
          render action: 'new'
        end
        format.js { render layout: false }
      end
    end
  end

  def destroy
    @category.is_delete = Time.now.to_i
    if @category.save
      respond_to do |format|
        format.js
      end
    else
      respond_with(@category) do |format|
        format.html { redirect_to location_after_destroy }
      end
    end
  end

  # 更新状态
  def update_status
     @category.update(status:params[:status])
  end


  private

  def set_category
    @category = Category.find(params[:id])
  end

  def permitted_resource_params
    params.require(:category).permit!
  end



end
