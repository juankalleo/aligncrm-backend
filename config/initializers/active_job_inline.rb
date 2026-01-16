# Force inline execution of Active Job in development to avoid requiring
# Redis/Sidekiq for ActiveStorage analysis/purge jobs while developing.
if Rails.env.development?
  ActiveJob::Base.queue_adapter = :inline
end
