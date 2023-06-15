class MemberAccessibleRepository < ActiveRecord::Base
  belongs_to :member
  belongs_to :repository

  validates :member_id, uniqueness: { scope: :repository_id}
end
