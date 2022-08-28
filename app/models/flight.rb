class Flight < ApplicationRecord
  has_many :airports

  has_many :search_results
  has_many :searches, through: :search_results
end
