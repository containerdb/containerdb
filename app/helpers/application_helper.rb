module ApplicationHelper

  def docker_version
    Docker.ping
    "#{Docker.url} v#{Docker.version['Version']}"
  rescue # Probably should not catch all errors
    content_tag :span, 'Disconnected', class: 'text-danger'
  end

end
