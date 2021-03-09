class Admin::CategoriesController < Admin::BaseController

  before_action :set_category, only: [:destroy,:edit,:show,:update,:update_status]
  skip_before_action :verify_authenticity_token

  def index
    @q = SearchParams.new(params[:search_params] || {})
    @categories = Category.default_where(@q.attributes(self)).page(params[:page]).per(50)
  end

  def new
    @category =  Category.new
    @category_conditions = [CategoryCondition.new]
  end

  def edit
    @category_conditions = @category.category_conditions
    @category_conditions = [CategoryCondition.new] unless @category_conditions.present?
  end

  def show

  end

  def create
    Category.transaction do 
      @category = Category.new(permitted_resource_params)
      if params[:category][:category_condition].present?
        params[:category][:category_condition].each do |index, spec|
          if spec[:classification_id].present? 
            @category.category_conditions.new(spec.permit!)
          end
        end
      end
      @category.save
      # 类型占比缓存
      @category.cache_condition 
    end
  end

  def update
    Category.transaction do 
      @category.update_attributes(permitted_resource_params)
      if params[:category][:category_condition].present?
        params[:category][:category_condition].each do |index, spec|
          spec.permit!
          if spec[:id].present?
            new_spec = CategoryCondition.find(spec[:id])
            new_spec.attributes = spec
            new_spec.save
          elsif spec[:classification_id].present? 
            new_spec = @category.category_conditions.find_or_create_by(classification_id:spec[:classification_id])
            new_spec.weight = spec[:weight] if spec[:weight].present?
            new_spec.tags_str = spec[:tags_str] if spec[:tags_str].present?
            new_spec.save
          end
        end
      end 
      # 类型占比缓存
      @category.cache_condition 
    end
  end

  def delete_condition
    @category_condition = CategoryCondition.find params[:condition_id].to_i
    @category_condition_id = @category_condition.id
    @category_condition.delete
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
    params.require(:category).permit!.except(:category_condition)
  end



end
