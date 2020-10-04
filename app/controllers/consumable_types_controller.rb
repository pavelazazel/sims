class ConsumableTypesController < ApplicationController
  def index
    @consumable_types = ConsumableType.order(:id)
  end

  def new
    @consumable_type = ConsumableType.new
  end

  def edit
    @consumable_type = ConsumableType.find(params[:id])
    @history = changes(@consumable_type)
  end

  def create
    @consumable_type = ConsumableType.new(consumable_type_params)
    if @consumable_type.save
      record_activity new_obj: @consumable_type
      redirect_to consumable_types_path
    else
      render :new
    end
  end

  def update
    @consumable_type = ConsumableType.find(params[:id])
    old_obj = @consumable_type.dup
    if @consumable_type.update(consumable_type_params)
      record_activity old_obj: old_obj, new_obj: @consumable_type
      redirect_to consumable_types_path
    else
      render :edit
    end
  end

  def destroy
    @consumable_type = ConsumableType.find(params[:id])
    @consumable_type.destroy
    record_activity old_obj: @consumable_type
    redirect_to consumable_types_path
  end

  private

  def consumable_type_params
    params.require(:consumable_type).permit(:title)
  end
end
