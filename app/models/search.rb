class Search < ApplicationRecord
  has_many :search_results
  has_many :flights, through: :search_results
end
