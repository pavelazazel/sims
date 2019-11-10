class ConsumablesController < ApplicationController
  def index
    @consumables = Consumable.all
  end

  def show
    @consumable = Consumable.find(params[:id])
  end

  def new
    @consumable = Consumable.new
  end

  def edit
    @consumable = Consumable.find(params[:id])
  end

  def create
    @consumable = Consumable.new(consumable_params)
    if @consumable.save
      redirect_to consumables_path
    else
      render :new
    end
  end

  def update
    @consumable = Consumable.find(params[:id])
    if @consumable.update(consumable_params)
      redirect_to @consumable
    else
      render :edit
    end
  end

  def destroy
    @consumable = Consumable.find(params[:id])
    @consumable.destroy
    redirect_to consumables_path
  end


  private

  def consumable_params
    params.require(:consumable).permit(:title,
                                       :name,
                                       :quantity_in_stock,
                                       :quantity_in_use,
                                       :quantity_ready_to_refill,
                                       :quantity_at_refill,
                                       :consumable_type_id)
  end
end
