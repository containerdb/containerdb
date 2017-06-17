require './config/boot'
require './config/environment'
include Clockwork

handler do |job|
  puts "Running #{job}"
  job.perform_async
end

every(1.day, BackupAllWorker, at: '00:00')
