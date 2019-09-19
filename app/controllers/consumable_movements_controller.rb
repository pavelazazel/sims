class ConsumableMovementsController < ApplicationController
  def index
    @consumable_movements = ConsumableMovement.all
  end

  def new
    @consumable_movement = ConsumableMovement.new
  end

  def create
    @consumable_movement = ConsumableMovement.new(consumable_movement_params)
    if @consumable_movement.save
      redirect_to consumable_movements_path
    else
      render :new
    end
  end

  def destroy
    @consumable_movement = ConsumableMovement.find(params[:id])
    @consumable_movement.destroy
    redirect_to consumable_movements_path
  end


  private

  def consumable_movement_params
    params.require(:consumable_movement).permit(:consumable_id, :location_id)
  end
end
