require "helpers"
class SchoolQueue
  include Mongoid::Document

  # ATTRIBUTES

  field :title, type: String
  field :active, type: Boolean, default: true
  field :frozen, type: Boolean, default: false
  field :is_question_based, type: Boolean, default: false
  field :class_number, type: String
  field :status, type: String, default: ""
  field :password, type: String

  # ASSOCIATIONS

  belongs_to :instructor
  has_many :queue_users, dependent: :destroy
  has_many :in_queue_durations, dependent: :nullify
  # These associations work out of the box because of inheritance! Whoop whoop!
  has_many :tas
  has_many :students

  # VALIDATIONS

  validates :frozen, :active, :is_question_based, :inclusion => { :in => [true, false], :message => "must be a true/false value" }
  validates :title, :class_number, :password, :presence => true
  validates :class_number, format: { with: /^\w*$/, message: "Must contain only letters, numbers, and underscores." }
  validates :class_number, uniqueness: { scope: :instructor_id }

  # SCOPES

  # CALLBACKS
  before_save :check_active
  before_save :upcase_class_number

  def to_param
    class_number
  end

  private
    
    def check_active
      if !active
        self.students.update_all(:in_queue => nil)
        self.tas.each { |ta| ta.student = nil ; ta.save }
        self.frozen = false
        self.status = ""
      end
    end

    def upcase_class_number
      self.class_number.upcase!
    end

end
