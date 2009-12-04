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

    def self.setup_availability
      yield(AvailabilityBuilder.new)
    end
  end

  class AvailabilityBuilder
    def disable(controller_group_name)
      ControllerGroup.disable(controller_group_name)
    end

    def enable(controller_group_name)
      ControllerGroup.enable(controller_group_name)
    end
  end

  # implements the DSL for managing controller groups in config/controllers.rb
  class ControllerGroupBuilder
    def initialize
      ControllerGroup.all = []
    end

    # add entry for controller group with name and options
    def controller_group(name, options = {})
      options[:in_menu] = true if options[:in_menu].nil?
      options[:enabled] = true if options[:enabled].nil?

      controllers = yield(ControllerBuilder.new)
      controllers.each { |c| ControllerGroup.controllers_hash[c] = true }
      ControllerGroup.add_controller_group ControllerGroup.new(name, controllers, options[:in_menu], options[:enabled])
    end
  end

  # implements the DSL for managing controllers in config/controllers.rb
  class ControllerBuilder
    def initialize
      @all = []
    end

    def controller(name, options = {})
      @all << name.to_s
    end
  end

  # implements the DSL for managing roles in config/routes.rb
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

