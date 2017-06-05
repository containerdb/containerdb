module ApplicationHelper

  def docker_version
    Docker.ping
    content_tag :span, "#{Docker.url} v#{Docker.version['Version']}", class: 'text-success'

  rescue # Probably should not catch all errors
    content_tag :span, 'Disconnected', class: 'text-danger'
  end

end
