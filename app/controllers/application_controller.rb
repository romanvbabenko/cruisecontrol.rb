# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  before_filter :set_time_zone

  def render_not_found
    render :file => Rails.root.join('public', '404.html').to_s, :status => 404
  end

  def disable_build_triggers
    return unless Configuration.disable_admin_ui
    render :text => 'Build requests are not allowed', :status => :forbidden
  end

  protected

  def set_time_zone
    Time.zone = request.env.fetch('rack.timezone.utc_offset', 0).to_i / 3600
  end
end
