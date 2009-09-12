class User
  include DataMapper::Resource
 
  attr_accessor :password, :password_confirmation
 
  property :id, Serial, :writer => :protected, :key => true
  property :email, String, :nullable => false, :length => (5..40), :unique => true, :format => :email_address
  property :username, String, :nullable => false, :length => (2..32), :unique => true
  property :hashed_password, String, :writer => :protected
  property :salt, String, :nullable => false, :writer => :protected
  property :created_at, DateTime
  property :account_type, String, :nullable => false, :default => 'standard', :writer => :protected
  property :active, Boolean, :default => true, :writer => :protected
  property :lat, String
  property :long, String
  property :twitter, String
  property :mobile, String
  
  has n, :searches
  
  validates_present :password_confirmation
  validates_is_confirmed :password
 
  # Authenticate a user based upon a (username or e-mail) and password
  # Return the user record if successful, otherwise nil
  def self.authenticate(username_or_email, pass)
    current_user = first(:username => username_or_email) || first(:email => username_or_email)
    return nil if current_user.nil? || User.encrypt(pass, current_user.salt) != current_user.hashed_password
    current_user
  end  
 
  # Set the user's password, producing a salt if necessary
  def password=(pass)
    @password = pass
    self.salt = (1..12).map{(rand(26)+65).chr}.join if !self.salt
    self.hashed_password = User.encrypt(@password, self.salt)
  end
 
  protected
  def self.encrypt(pass, salt)
    Digest::SHA1.hexdigest(pass + salt)
  end
end            
