namespace :website do
  desc "stop unicorn_rails"
  task :stop do
    puts %x{ps aux | grep unicorn_rails | grep master | awk '{print $2}' | xargs -n 1 kill}
  end

  desc "start unicorn_rails"
  task :start do
    puts %x{nohup unicorn_rails -p 3000 -E production & }
  end

  desc "restart unicorn_rails"
  task :restart do
    puts %x{ps aux | grep unicorn_rails | grep master | awk '{print $2}' | xargs -n 1 kill}
    puts %x{nohup unicorn_rails -p 3000 -E production & }
  end
end