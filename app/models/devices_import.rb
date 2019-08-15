class DevicesImport
  include ActiveModel::Model
  require 'roo'

  attr_accessor :file

  def initialize(attributes={})
    attributes.each { |id, inventory_number| send("#{id}=", inventory_number) }
  end

  def persisted?
    false
  end

  def open_spreadsheet
    case File.extname(file.original_filename)
    when ".csv" then Csv.new(file.path, nil, :ignore)
    when ".xls" then Roo::Excel.new(file.path, nil, :ignore)
    when ".xlsx" then Roo::Excelx.new(file.path)
    else raise "Unknown file type: #{file.original_filename}"
    end
  end

  def load_imported_devices
    spreadsheet = open_spreadsheet
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).map do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      # TODO: need do something with id. Attribute "id" can't be edit manually now.
      #       So, find_by_id not working. Only import at empty database working now.
      device = Device.find_by_id(row["id"]) || Device.new
      row["id"] = i - 1
      device.attributes = row.to_hash
      device.created_at = Time.now
      device.updated_at = Time.now
      device
    end
  end

  def imported_devices
    @imported_devices ||= load_imported_devices
  end

  def save
    if imported_devices.map(&:valid?).all?
      imported_devices.each(&:save!)
      true
    else
      imported_devices.each_with_index do |device, index|
        device.errors.full_messages.each do |msg|
          errors.add :base, "Row #{index + 6}: #{msg}"
        end
      end
      false
    end
  end

end
