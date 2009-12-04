module PermissionSystem
  class Role < Struct.new :name, :permissions, :parent
    cattr_accessor :all
    attr_accessor :available_controller_groups

    def self.build
      return @@all unless @@all.blank?
      @@all = []
      ControllerGroup.build
      load PermissionSystem.roles_file
    end

    # list all the controller groups this role has access to (through assigned controllers)
    # also, the call is cached
    def available_controller_groups
      return @available_controller_groups unless @available_controller_groups.nil?

      @available_controller_groups = []
      ControllerGroup.all.each do |group|
        next unless group.in_menu
        @available_controller_groups.push(group) unless group.first_available_controller(self).nil?
      end

      @available_controller_groups
  #  memoize :available_controller_groups
    end

    # find the role specified by name
    def self.find(name)
      return nil if all.blank?

      all.select{|x| x.name==name}.first
    end

    # find the appropriate permission for the controller and action
    def find_permission(controller, action)
      # if the controller group isn't enabled return nil
      return nil if ControllerGroup.find_controller(controller).nil?

      if is_root?
        return Permission.new(controller, action, true) # TODO is_god, hardcoded true
      end

      result = permissions.select do |p|
        p.controller==controller && action=~Regexp.new(p.action)
      end

      raise "Problem, too many results for find_permission for controller #{controller}" if result.size>1

      if result.blank?
        if parent
          return parent.find_permission(controller, action)
        else
          nil
        end
      else
        result.first
      end
    end

    # does this role have permission for the controller and action
    def has_permission(controller, action)
      find_permission(controller, action) != nil
    end

    # TODO fali mi oblik metode koje ce pitati "da li si root ili neki od kojih on naslijedjuje dozvole?"
    # mozda inherits_root?
    def method_missing(*args)
      method_name = args.first.to_s
      if method_name=~/is_.*[?]/
        roles = method_name.gsub(/is_(.*)[?]/, "\\1")
        roles.split("_or_").each do |role|
          return name.underscore==role
        end
      elsif method_name=~/has_.*[?]/
        controller = args.second
        action = method_name.gsub(/has_(.*)[?]/, "\\1")
        return has_permission(controller, action)
      else
        super(*args)
      end
    end
  end
end

