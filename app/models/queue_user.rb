class QueueUser
  include Mongoid::Document

  # ATTRIBUTES

  field :username, type: String
  field :token, type: String, default: -> { SecureRandom.uuid }
  field :location, type: String
  field :alive_time, type: DateTime, default: -> { DateTime.now }

  # ASSOCIATIONS
  
  belongs_to :school_queue

  # VALIDATIONS
  
  validates :username, :token, :presence => true
  validates :username, :length => { :within => 1..40 }

  # TODO: I don't like this being server-side, clients should take care of this - pwightman
  validates :username, :exclusion => { :in => ["username", "Username", "name", "Name"], :message => "Please choose a different username" }

  # SCOPES
  
  # CALLBACKS

  def queue
    self.school_queue
  end

  def ta?
    self.class == Ta
  end

  def student?
    self.class == Student
  end

  def keep_alive 
    if self.alive_time.nil?
      self.alive_time = DateTime.now
      self.save
      logger.debug "Alive time updated"
    else
      if self.alive_time + 15.minutes < DateTime.now
        self.alive_time = DateTime.now
        self.save
        logger.debug "Alive time updated"
      end
    end
  end

end
