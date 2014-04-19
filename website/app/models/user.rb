class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable, :authentication_keys => [:login]
  
  validates :username, :uniqueness => {:case_sensitive => false}

  #attr_accessor :login

  def login=(login)
    @login = login
  end

  def login
    @login || self.username || self.email
  end

    def self.find_first_by_auth_conditions(warden_conditions)
      conditions = warden_conditions.dup
      #puts "========="+conditions.inspect
      if login = conditions.delete(:login)
      	#where(conditions).where(["username = :value OR lower(email) = lower(:value)", { :value => login }]).first
        where(conditions).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
      else
        where(conditions).first
      end
    end
end
