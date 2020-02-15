class ConsumablesController < ApplicationController
  protect_from_forgery except: [:get_consumables, :refill]

  def index
    @consumables = Consumable.order(:id)
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

  def get_types
    types = ConsumableType.all.order(:id)
    respond_to do |format|
      format.json { render json: types }
    end
  end

  def get_consumables
    consumables = Consumable.where(consumable_type_id: params[:type_id])
    respond_to do |format|
      format.json { render json: consumables }
    end
  end

  def refill
    is_saved = false
    params[:counters].each do |counter|
      consumable = Consumable.find(counter[:id])
      case params[:act]
      when 'send'
        ready = consumable.quantity_ready_to_refill - counter[:count]
        already = consumable.quantity_at_refill + counter[:count]
        is_saved = consumable.update(quantity_ready_to_refill: ready,
                                     quantity_at_refill: already)
      when 'get'
        already = consumable.quantity_at_refill - counter[:count]
        stock = consumable.quantity_in_stock + counter[:count]
        is_saved = consumable.update(quantity_at_refill: already,
                                     quantity_in_stock: stock)
      else
        raise ArgumentError, 'Art is not a "send" or "get"'
      end
    end
    respond_to do |format|
      format.json { render json: is_saved }
    end
  end

  private

  def consumable_params
    params.require(:consumable).permit(:title,
                                       :name,
                                       :quantity_in_stock,
                                       :quantity_in_use,
                                       :quantity_ready_to_refill,
                                       :quantity_at_refill,
                                       :consumable_type_id,
                                       :placement)
  end
end
