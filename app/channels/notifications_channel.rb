class NotificationsChannel < ApplicationCable::Channel
  def subscribed
    user = fetch_user_from_token
    return reject if user.blank?

    stream_for user
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  private

  def fetch_user_from_token
    UserFinder.new(params[:token]).perform
  end
end
