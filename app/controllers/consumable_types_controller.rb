class ConsumableTypesController < ApplicationController
  def index
    @consumable_types = ConsumableType.all
  end

  def new
    @consumable_type = ConsumableType.new
  end

  def edit
    @consumable_type = ConsumableType.find(params[:id])
  end

  def create
    @consumable_type = ConsumableType.new(consumable_type_params)
    if @consumable_type.save
      redirect_to consumable_types_path
    else
      render :new
    end
  end

  def update
    @consumable_type = ConsumableType.find(params[:id])
    if @consumable_type.update(consumable_type_params)
      redirect_to @consumable_type
    else
      render :edit
    end
  end

  def destroy
    @consumable_type = ConsumableType.find(params[:id])
    @consumable_type.destroy
    redirect_to consumable_types_path
  end

  private

  def consumable_type_params
    params.require(:consumable_type).permit(:title)
  end
end
