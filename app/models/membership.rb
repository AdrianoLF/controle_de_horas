class Membership < ApplicationRecord
  belongs_to :planilha
  belongs_to :member
end
