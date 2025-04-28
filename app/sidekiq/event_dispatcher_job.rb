class EventDispatcherJob
  include Sidekiq::Job
  sidekiq_options queue: :high

  def perform(user_id, message)
    user = User.find(user_id)
    NotificationsChannel.broadcast_to(user, { message: message })
  end
end
