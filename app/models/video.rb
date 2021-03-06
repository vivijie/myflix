class Video < ActiveRecord::Base
  belongs_to :category
  has_many :reviews
  has_many :queue_items

  mount_uploader :large_cover, LargeCoverUploader
  mount_uploader :small_cover, SmallCoverUploader

  validates_presence_of :title, :description

  def self.search_by_title(search_term)
    return [] if search_term.blank?
    where("title LIKE ?", "%#{search_term}%").order("created_at DESC")
  end

  def average_rate(video)
    video.reviews.average('rate').round(1) if video.nil?
  end
end
