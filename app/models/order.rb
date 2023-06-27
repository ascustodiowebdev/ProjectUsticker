class Order < ApplicationRecord
  validates :phone_number, presence: true
  has_and_belongs_to_many :stickers
end
