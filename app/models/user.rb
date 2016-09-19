class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  attr_accessor :login

  validates :username, presence: true, uniqueness: {case_sensitive: false},
    format: {without: /@/, message: :contains_atc}

  has_many :posts
  has_many :comments

  class << self
    def find_for_database_authentication warden_conditions
      conditions = warden_conditions.dup
      login = conditions.delete(:login).try :downcase
      where(conditions).where(email: login).or(where(conditions).where(username: login)).first
    end
  end
end
