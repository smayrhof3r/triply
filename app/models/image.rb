class Image < ApplicationRecord
  belongs_to :location # , dependent: :destroy
end
