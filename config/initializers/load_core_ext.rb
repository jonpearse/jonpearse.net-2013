Dir[Rails.root+'lib/core_ext/*.rb'].each do |f|
  require f
end