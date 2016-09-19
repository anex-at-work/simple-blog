class Post < ActiveRecord::Base
  audited
  acts_as_taggable

  belongs_to :user
  has_many :comments

  enum status: {
    published: 0,
    unpublished: 1,
    deleted: 2
  }

  after_initialize :after_init

  validates :name, :published_at, :content, presence: true

  scope :with_user, -> do
    eager_load(:user)
  end

  scope :avaliable, -> (u) do
    cond = with_user.published
    u.nil? ? cond.where('published_at <= NOW()') : cond.or(Post.where(user_id: u.id).unpublished)
  end

  def delete
    deleted!
  end

  def can_edit_by? u
    !u.nil? && u.id == user_id
  end

  private
  def after_init
    self.published_at = Time.zone.now if self.published_at.nil?
  end
end
