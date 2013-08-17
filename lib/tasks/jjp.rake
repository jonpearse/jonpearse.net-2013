namespace :jjp do
  desc "Performs some maintenance tasks"
  task :clean_up do

    puts "Cleaning old previews"
    Rake::Task['jjp:content:clean_previews'].invoke
    
  end
  
  namespace :content do
    desc "Removes stale previews"
    task :clean_previews => :environment do      

      Preview.clean_old
      
    end
  end
end