class Machine < ApplicationRecord

  validates :name, presence: true

  has_many :services
end
