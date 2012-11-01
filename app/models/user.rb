class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :rememberable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  # attr_accessible :title, :body
  attr_accessible :email, :password, :admin, :as => :admin

  has_many :surveys, dependent: :destroy

  default_scope order: 'email'

  def to_s
    "#{email} (#{admin? ? "Admin" : "User"})"
  end
end
