class Comment < ActiveRecord::Base
  acts_as_nested_set scope: :post

  audited
  belongs_to :post
  belongs_to :user

  enum status: {
    published: 0,
    deleted: 1
  }

  validates :comment, presence: true

  scope :with_user, -> do
    eager_load(:user)
  end

  def can_edit_by? u
    !u.nil? && published? && u.id == user_id && self.class.avaliable_time < created_at
  end

  def delete
    deleted!
  end

  class << self
    def avaliable_time
      15.minutes.ago # magic-number
    end
  end

end
