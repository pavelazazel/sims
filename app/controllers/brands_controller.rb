class BrandsController < ApplicationController
  def index
    @brands = Brand.order(:id)
  end

  def new
    @brand = Brand.new
  end

  def edit
    @brand = Brand.find(params[:id])
    @history = changes(@brand)
  end

  def create
    @brand = Brand.new(brand_params)
    if @brand.save
      record_activity new_obj: @brand
      redirect_to brands_path
    else
      render :new
    end
  end

  def update
    @brand = Brand.find(params[:id])
    old_obj = @brand.dup
    if @brand.update(brand_params)
      record_activity old_obj: old_obj, new_obj: @brand
      redirect_to brands_path
    else
      render :edit
    end
  end

  def destroy
    @brand = Brand.find(params[:id])
    @brand.destroy
    record_activity old_obj: @brand
    redirect_to brands_path
  end

  private

  def brand_params
    params.require(:brand).permit(:title)
  end
end
