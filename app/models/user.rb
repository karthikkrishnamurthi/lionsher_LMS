# Server Side Validations. Database Associations
# Author : Aarthi

require 'digest/sha1'
class User < ActiveRecord::Base
  has_attached_file :bugz_profile, :styles => { :thumb => "32x32" }
  has_many :issues
  belongs_to :post
  # Virtual attribute for the unencrypted password
  attr_accessor :password
  attr_protected
  validates_presence_of     :login, :email
  validates_length_of       :login,    :within => 1..40
  validates_length_of       :email,    :within => 6..256
#  validates_format_of :email,:with =>  /^([A-Za-z0-9_\-\.])+\@([A-Za-z0-9_\-\.])+\.([A-Za-z]{2,4})$/
  before_create :make_activation_code 
  after_save :send_after_save_mail
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  #attr_accessible :login, :email, :password, :password_confirmation, :reset_code

  belongs_to :tenant
  has_one   :tenants
  has_many  :user
  has_many  :courses
  has_many  :assessments
  has_many  :learners
  has_many  :question_banks
  belongs_to  :group
  has_many   :groups
  has_many :descriptive_answers
  has_many  :emails
  has_many  :packages
  has_many  :calculated_data_learner_assessments

  # Activates the user in the database.
  def activate
    @activated = true
    self.activated_at = Time.now.utc
    self.activation_code = nil
    save(:validate => false)
  end

  def active?
    # the existence of an activation code means they have not activated yet
    activation_code.nil?
  end

  def send_after_save_mail
    if recently_reset? 
      UserMailer.reset_notification(self).deliver
    end
  end

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(email, password)
    u = find :first, :conditions => ['email = ? and activated_at IS NOT NULL', email] # need to get the salt
      u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
      crypted_password == Digest::SHA1.hexdigest(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = Digest::SHA1.hexdigest("#{email}--#{remember_token_expires_at}")
    save(:validate => false)
  end

  # Returns true if the user has just been activated.
  def recently_activated?
    @activated
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(:validate => false)
  end
  
  #create reset code and save without validation and set @reset object to true
  def create_reset_code
    @reset = true
    self.attributes = {:reset_code => Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )}
    save(:validate => false)
  end

  def recently_reset?
    return @reset
  end

  def delete_reset_code
    self.attributes = {:reset_code => nil}
    save(:validate => false)
  end

  protected
  # before filter
  def encrypt_password
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
    self.crypted_password = encrypt(password)
  end
      
  def password_required?
    crypted_password.blank? || !password.blank?
  end
    
  def make_activation_code
    self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
  end
    
end
