class TypesController < ApplicationController
  def index
    @types = Type.order(:id)
  end

  def new
    @type = Type.new
  end

  def edit
    @type = Type.find(params[:id])
    @history = changes(@type)
  end

  def create
    @type = Type.new(type_params)
    if @type.save
      record_activity new_obj: @type
      redirect_to types_path
    else
      render :new
    end
  end

  def update
    @type = Type.find(params[:id])
    old_obj = @type.dup
    if @type.update(type_params)
      record_activity old_obj: old_obj, new_obj: @type
      redirect_to types_path
    else
      render :edit
    end
  end

  def destroy
    @type = Type.find(params[:id])
    @type.destroy
    record_activity old_obj: @type
    redirect_to types_path
  end

  private

  def type_params
    params.require(:type).permit(:title)
  end
end
