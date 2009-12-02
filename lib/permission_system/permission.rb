module PermissionSystem
  class Permission < Struct.new :controller, :action, :is_god
  end
end

