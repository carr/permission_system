module PermissionSystem
  class ControllerGroup < Struct.new(:name, :controllers, :in_menu, :enabled)
    cattr_accessor :all, :controllers_hash

    def self.build
      return @@all unless @@all.blank?

      @@controllers_hash = {}
      load PermissionSystem.controllers_file
    end

    # reload all the controller groups from the config file
    def self.reload!
      @@all = nil
      build
    end

    # list all the enabled controller groups
    def self.all
      @@all.select{|c| c.enabled}
    end

    # add the specified controller group
    def self.add_controller_group(cg)
      @@all << cg
    end

    # find the controller group with the specified name
    def self.find_controller_group(controller_group_name)
      cg = @@all.select{|c| c.name == controller_group_name }
      raise "No controller group with name #{controller_group_name}" if cg.blank?
      cg.first
    end

    # enable the specified controller group
    def self.enable(controller_group_name)
      cg = find_controller_group(controller_group_name)
      cg.enabled = true
    end

    # disable the specified controller group
    def self.disable(controller_group_name)
      cg = find_controller_group(controller_group_name)
      cg.enabled = false
    end

    # checks if this controller exists and returns its name
    # in the future if controllers have additional properties this will return them
    def self.find_controller(controller)
#      @@controllers_hash.has_key?(controller) ? controller : nil
      cgs = all.find{|cg| cg.controllers.member?(controller) }
      cgs.blank? ? nil : controller
    end

    # checks if the controller group contains this controller
    def has_controller?(controller)
      controllers.member?(controller)
    end

    # find the first controller that role has access in this controller group
    def first_available_controller(role)
      controllers.select{|c| role.has_permission(c, 'index')}.first
    end

    def update_from_source!
      # TODO
    end
  end
end

