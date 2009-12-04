module PermissionSystem
  mattr_accessor :roles_file
  mattr_accessor :controllers_file
  mattr_accessor :modules_file

  def self.included(base)
    self.roles_file ||= "#{RAILS_ROOT}/config/roles.rb"
    self.controllers_file ||= "#{RAILS_ROOT}/config/controllers.rb"
    self.modules_file ||= "#{RAILS_ROOT}/config/available_modules.rb"

    raise "Roles file doesn't exist at #{self.roles_file}'" unless File.exists?(self.roles_file)
    raise "Controllers file doesn't exist at #{self.controllers_file}'" unless File.exists?(self.controllers_file)

    Role.build
    load self.modules_file if File.exists?(self.modules_file)
  end

  def check_login
    @current_role = Role.find('Public')
    if (!logged_in?)
      redirect_to login_path(:referrer => request.url) if !check_public_access
    end
  end

  def check_public_access
    @current_role.has_permission(controller_name, action_name)
  end

  def check_authorization
    if @current_role.has_permission(controller_name, action_name)
      # check_god_permission(permission) # TODO implementirat god
    else
      redirect_to authorization_error_path
    end
  end

  def current_model
    controller_name.singularize.camelize
  end

  def current_role
    current_user if @current_user.nil? # current_user metoda postavlja current_role pa ju moramo pozvat
    @current_role
  end

  def check_god_permission(permission)
    if !permission.is_god?
      extend_model current_model
    end
  end

  def extend_model(model_name)
    begin
      eval("
        #{model_name}.class_eval(\"
          def self.find(*args)
            args.push(:conditions => 'created_by = #{@current_user.id}')
            super(*args)
          end
        \") if #{model_name}.column_names.member?('created_by')
      ")
    rescue
      puts "Model doesn't exist #{model_name}"
    end
  end

end

