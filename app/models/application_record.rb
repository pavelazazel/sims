class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def history_title
    self.title
  end
end
