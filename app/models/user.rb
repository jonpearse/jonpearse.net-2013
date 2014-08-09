class User < ActiveRecord::Base
	attr_accessor :gauth_token
  include Errorable
  
  devise :google_authenticatable, :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable

  attr_accessor :login

  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    else
      where(conditions).first
    end
  end

  def first_time?
    !updated
  end

  def twofa_enabled?
    gauth_enabled == '1'
  end

  def regenerate_secret!
    assign_auth_secret
    self.save
  end
end
