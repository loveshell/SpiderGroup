ENV["RAILS_ENV"] ||= "production"

module UnicornServer
  # http://unicorn.bogomips.org/Unicorn/Configurator.html
  CONFIG_PATH = File.join(Rails.root, "config", "unicorn.rb")
  PID_PATH = File.join(Rails.root, "tmp", "unicorn.pid")
  RBENV = %x[which rbenv].strip
  DAEMON = "bundle exec unicorn_rails"
  DAEMON_OPTS = "-c #{CONFIG_PATH} -E #{ENV["RAILS_ENV"]} -D"

  def self.rbenv_cmd
    return nil if RBENV.blank?
    "#{RBENV} rehash;"
  end

  def self.unicorn_pid
    if File.exists?(PID_PATH)
      File.read(PID_PATH).strip
    else
      nil
    end
  end

  def self.unicorn_rails_start_cmd
    ["cd #{Rails.root};", rbenv_cmd, DAEMON, DAEMON_OPTS].join(" ")
  end

  def self.send_signal_if_unicorn_pid_exists(signal)
    puts "pid is #{unicorn_pid}"
    abort "Couldn't find unicorn pid '#{PID_PATH}'" if unicorn_pid.blank?
    system "kill -s #{signal} #{unicorn_pid}"
  end
end

# https://gist.github.com/2044650
namespace :unicorn do
  desc "Start unicorn server"
  task :start => :environment do
    abort "Already running" unless UnicornServer.unicorn_pid.blank?
    system UnicornServer.unicorn_rails_start_cmd
  end

  desc "Stop unicorn server"
  task :stop => :environment do
    abort "Not running" if UnicornServer.unicorn_pid.blank?
    UnicornServer.send_signal_if_unicorn_pid_exists("TERM")
  end

  desc "Executes 'rake unicorn:stop; rake unicorn:start'"
  task :restart => :environment do
    begin
      UnicornServer.send_signal_if_unicorn_pid_exists("TERM")
    rescue Exception
      puts "Couldn't reload, starting '#{UnicornServer.unicorn_rails_start_cmd}' instead"
      system UnicornServer.unicorn_rails_start_cmd
    else
      unless UnicornServer.unicorn_pid.blank?
        UnicornServer.send_signal_if_unicorn_pid_exists("TERM")
      end

      puts "Couldn't reload, starting '#{UnicornServer.unicorn_rails_start_cmd}' instead"
      system UnicornServer.unicorn_rails_start_cmd
    end
  end

  desc "Reloads config file and gracefully restart all workers, calling a Gem.refresh " +
           "in order to reload newly installed gems"
  task :graceful_restart => :environment do
    UnicornServer.send_signal_if_unicorn_pid_exists("HUP")
  end

  desc "Executes a graceful stop (waits for workers to finish their current request before finishing)"
  task :graceful_stop => :environment do
    UnicornServer.send_signal_if_unicorn_pid_exists("QUIT")
  end

  desc "Reexecute the running binary"
  task :reload => :environment do
    UnicornServer.send_signal_if_unicorn_pid_exists("USR2")
  end

  # desc "Gracefully stops workers but keep the master running"
  # task :standby => :environment do
  #   UnicornServer.send_signal_if_unicorn_pid_exists("WINCH")
  # end

  # desc "Reopen logs"
  # task :reopen_logs => :environment do
  #   UnicornServer.send_signal_if_unicorn_pid_exists("USR1")
  # end

  # desc "Increment workers"
  # task :add_worker => :environment do
  #   UnicornServer.send_signal_if_unicorn_pid_exists("TTIN")
  # end

  # desc "Decrement workers"
  # task :remove_worker => :environment do
  #   UnicornServer.send_signal_if_unicorn_pid_exists("TTOU")
  # end
end