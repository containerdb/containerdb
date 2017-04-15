class Backup < ApplicationRecord

  belongs_to :service

  enum status: { pending: 0, running: 1, complete: 2, failed: 3 }
end
