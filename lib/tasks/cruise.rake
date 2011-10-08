namespace :cruise do

  task :info do
    # Add local user gem path, in case rcov was installed with non-root access
    ENV['PATH'] = "#{ENV['PATH']}:#{File.join(Gem.user_dir, 'bin')}"

    puts
    puts "[CruiseControl] === Build environment ==="  if File.exist?('/etc/issue')
    puts "[CruiseControl]   #{`cat /etc/issue`}"      if File.exist?('/etc/issue')

    puts "[CruiseControl] === System information ==="
    puts "[CruiseControl]   #{`uname -a`}"

    puts "[CruiseControl] === Ruby information ==="
    puts "[CruiseControl]   #{`ruby -v`}"

    puts "[CruiseControl] === Gem information ==="
    `ruby -S gem env`.each_line  {|line| print "[CruiseControl]    #{line}"}

    puts "[CruiseControl] === Local gems ==="
    `ruby -S gem list`.each_line {|line| print "[CruiseControl]    #{line}"}
    puts
  end

  desc "Continuous build target"
  task :all => [:info, 'rcov'] do
    out = ENV['CC_BUILD_ARTIFACTS']
    mkdir_p out unless File.directory? out if out
    mv 'reports/rcov', "#{out}" if out
  end

  desc "Kill all builders"
  task :'builder:kill_them_all' => :environment do
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
  end
end


desc 'Continuous build target'
task :cruise => ['cruise:all']
