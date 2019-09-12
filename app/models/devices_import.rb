class DevicesImport
  include ActiveModel::Model
  require 'roo'

  attr_accessor :file

  def initialize(attributes={})
    attributes.each { |name, value| send("#{name}=", value) }
  end

  # This method tells rails that this object has no related table in our database.
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

  def load_imported_data(model)
    spreadsheet = open_spreadsheet  # load from file
    header = spreadsheet.sheet("#{model}s").row(1)  # first row - names of attributes

    # from second row starting load data row by row
    (2..spreadsheet.last_row).map do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      data = model.find_by_id(row["id"]) || model.new
      data.attributes = row.to_hash
      data.created_at = Time.now
      data.updated_at = Time.now
      data
    end
  end

  def save
    models = [Type, Brand, Location, Name, Device]  # all models to array

    # import to models data from excel spreadsheet
    models.each do |model|
      imported_data ||= load_imported_data(model)
      if imported_data.map(&:valid?).all?
        imported_data.each(&:save!)
        true
      else
        imported_data.each_with_index do |data, index|
          data.errors.full_messages.each do |msg|
            errors.add :base, "Row #{index + 1}: #{msg}"
          end
        end
        false
      end
    end
  end

end