module PermissionSystem
  class Builder
    # method for setting up controller in config/controllers.rb
    def self.setup_controllers
      yield(ControllerGroupBuilder.new)
    end

    # method for setting up routes in config/routes.rb
    def self.setup_roles
      yield(RoleBuilder.new(nil))
    end
  end

  class ControllerGroupBuilder
    def initialize
      ControllerGroup.all = []
    end

    # add entry for controller group with name and options
    def controller_group(name, options = {})
      options[:in_menu] = true if options[:in_menu].nil?
      controllers = yield(ControllerBuilder.new)
      ControllerGroup.all << ControllerGroup.new(name, controllers, options[:in_menu])
    end
  end

  class ControllerBuilder
    def initialize
      @all = []
    end

    def controller(name, options = {})
      @all << name.to_s
    end
  end

  class RoleBuilder
    attr_accessor :auto_god, :all_permissions, :permissions

    def initialize(parent)
      @parent = parent
      @permissions = []
    end

    # create a new role with appropriate options
    def role(name, options = {})
      new_role = Role.new(name, [], @parent)
      rb = RoleBuilder.new(new_role)
      yield(rb)
      new_role.permissions = rb.permissions
      Role.all << new_role
    end

    # grants a permissions for this controller and options
    def grant(controller, options = {})
      options[:is_god] ||= false # TODO autogod
      options[:on] ||= :all
      if options[:on].kind_of? Array
        options[:on] = options[:on].join("|")
      end
      value = options[:on]==:all ? ":*" : options[:on]

      @permissions << Permission.new(controller.to_s, value, options[:is_god])
    end

    # grants all permissions to this role. overwrites all other permissions
    def grant_all!
      @all_permissions=true
    end
  end
end

