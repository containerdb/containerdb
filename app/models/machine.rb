class Machine < ApplicationRecord

  validates :name, presence: true
  validates :hostname, presence: true
  validates :data_directory, presence: true

  has_many :services

  def docker
    Docker::Connection.new(docker_url, docker_options)
  end

  def docker_options
    {}
  end
end
