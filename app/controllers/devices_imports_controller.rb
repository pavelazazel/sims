class DevicesImportsController < ApplicationController
  def new
    @devices_import = DevicesImport.new
  end

  def create
    @devices_import = DevicesImport.new(params[:devices_import])
    if @devices_import.save
      record_activity action: 'update', object_type: 'database',
                      object_id: '0', info: 'excel file uploaded - all information updated'
      redirect_to devices_path
    else
      render :new
    end
  end
end
