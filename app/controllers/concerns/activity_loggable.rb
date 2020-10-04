module ActivityLoggable
  extend ActiveSupport::Concern

  class UserMeta
    attr_reader :id, :browser, :ip

    def initialize browser, ip
      @id = -1
      @browser = browser
      @ip = ip
    end

    def attributes
      [['browser', @browser], ['ip', @ip]]
    end
  end

  def user_meta browser, ip
    UserMeta.new browser, ip
  end

  def last_changes obj
    result = []
    users = []
    strs = []
    history = UserActivity.where(object_type: controller_name.singularize,
                                 object_id: obj.id).order("created_at DESC").take(6)
    history.each do |h|
      users.append(h.user)
      strs.append(' [' + h.created_at.to_s + '] ' +
                         h.user.username + ' ' +
                         h.action + ' ' +
                         h.object_type +
                         (h.info.blank? ? '' : ": #{h.info}"))
    end
    result.append(users, strs)
  end

  def changes_info old_obj, new_obj
    result = ''
    old_attrs = attrs_include_objects old_obj
    new_attrs = attrs_include_objects new_obj
    if old_attrs && new_attrs
      old_attrs.each_index do |i|
        unless old_attrs[i] == new_attrs[i]
          result += ' [' + old_attrs[i].to_s + ' => ' + new_attrs[i].to_s + ']'
        end
      end
    else
      (old_attrs || new_attrs).each { |attr| result += attr + ' ' }
    end
    result
  end


  private

  def attrs_include_objects obj
    unless obj.nil?
      result = []
      attrs = obj.attributes.sort
      attrs.each do |attr|
        if attr[0][-3..-1] == '_id'
          result << attr[0][0..-3].classify.constantize.find(attr[1]).history_title
        else
          result << attr[1] unless attr[0] == 'id' ||
                                   attr[0] == 'created_at' ||
                                   attr[0] == 'updated_at'
        end
      end
    end
    result
  end
end
