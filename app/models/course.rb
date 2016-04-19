class Course < ActiveRecord::Base
  belongs_to :page_content
  belongs_to :subject
  validates_length_of :description, maximum: 200

  belongs_to :topic
  validates_length_of :description, maximum: 200

  has_many :lessons, dependent: :destroy

  validates_length_of :description, maximum: 400
  accepts_nested_attributes_for :page_content

  def subject=(s)
    if !s.nil? && s.kind_of?(String)
      s = Subject.find_or_initialize_by(value: s)
    end
    super(s)
  end

  def topic=(t)
    if !t.nil? && t.kind_of?(String)
      t = Topic.find_or_initialize_by(value: t)
    end
    super(t)
  end

  def subject_value
    if subject.nil?
      ''
    else
      subject.value
    end
  end

  def topic_value
    if topic.nil?
      ''
    else
      topic.value
    end
  end

  def page_content
    orig = super
    if orig.nil?
      orig = PageContent.new(content: '')
      self.page_content = orig
    end
    orig
  end

  def self.default
    new(page_content: PageContent.new(content: ''))
  end
end
