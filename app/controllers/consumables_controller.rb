class ConsumablesController < ApplicationController
  protect_from_forgery except: [:get_consumables, :refill]

  def index
    @consumables = Consumable.order(:id)
  end

  def show
    @consumable = Consumable.find(params[:id])
    @history = changes(@consumable)
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
      record_activity new_obj: @consumable
      redirect_to consumables_path
    else
      render :new
    end
  end

  def update
    @consumable = Consumable.find(params[:id])
    old_obj = @consumable.dup
    if @consumable.update(consumable_params)
      record_activity old_obj: old_obj, new_obj: @consumable
      redirect_to @consumable
    else
      render :edit
    end
  end

  def destroy
    @consumable = Consumable.find(params[:id])
    @consumable.destroy
    record_activity old_obj: @consumable
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
        if consumable.quantity_ready_to_refill != ready || consumable.quantity_at_refill != already
          is_saved = consumable.update(quantity_ready_to_refill: ready,
                                       quantity_at_refill: already)
          record_activity new_obj: consumable,
                          action: 'update',
                          info: " send #{consumable.consumable_type.title}
                                  #{consumable.title} (#{counter[:count]} pcs) to refill"
        end
      when 'get'
        already = consumable.quantity_at_refill - counter[:count]
        stock = consumable.quantity_in_stock + counter[:count]
        if consumable.quantity_in_stock != stock || consumable.quantity_at_refill != already
          is_saved = consumable.update(quantity_at_refill: already,
                                       quantity_in_stock: stock)
          record_activity new_obj: consumable,
                          action: 'update',
                          info: " get #{consumable.consumable_type.title}
                                  #{consumable.title} (#{counter[:count]} pcs) from refill"
        end
      else
        raise ArgumentError, 'Act is not a "send" or "get"'
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
