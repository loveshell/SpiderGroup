namespace :sg do
  desc "clean cache"
  task :c do
    puts %x{rm -rf ./lib/imgs/*}
  end

  desc "start spider with image download"
  task :s do
    puts %x{ruby spidergroup.rb -i 1 all}
  end
end
