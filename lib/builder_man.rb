class BuilderMan
  class << self
    def kill_them_all
      Project.all.each do |project|
        pid_file = Platform.project_pid_file(project.name)
        if pid_file.exist?
          if Platform.pid_ok?(pid_file.read.chomp)
            Platform.kill_project_builder(project.name) if Platform.pid_ok?(pid_file.read.chomp)
            puts "#{project.display_name} builder has been killed"
          else
            puts "Kill process #{pid_file.basename} has been FAILED"
          end
        end
      end
      nil
    end
  end
end
