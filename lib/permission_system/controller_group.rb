module PermissionSystem
  class ControllerGroup < Struct.new(:name, :controllers, :in_menu)
    cattr_accessor :all, :controllers_hash

    def self.build
      return @@all unless @@all.blank?
      load PermissionSystem.controllers_file
    end

    # reload all the controller groups from the config file
    def self.reload!
      @@all = nil
      build
    end

    # list all the controller groups, loading them first if necessary
    def self.all
      #if @@all.blank? then build else @@all end
      @@all
    end

    # checks if this controller exists and returns its name
    # in the future if controllers have additional properties this will return them
    def self.find_controller(controller)
      @@controllers_hash.has_key?(controller) ? controller : nil
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

