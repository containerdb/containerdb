class Machine < ApplicationRecord

  validates :name, presence: true

  has_many :services

  def docker
    Docker::Connection.new(docker_url, docker_options)
  end

  def docker_options
    {}
  end
end
