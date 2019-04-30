# == Schema Information
#
# Table name: pages
#
#  id            :bigint(8)        not null, primary key
#  website_id    :integer
#  url           :string(4096)
#  title         :string(1024)
#  content_type  :string
#  content       :text
#  response_code :integer
#  referrer      :string(4096)
#  status        :integer          default("uncrawled")
#  visited_at    :datetime
#  message       :string
#  digest        :string(64)
#  created_at    :datetime
#  updated_at    :datetime
#
# Indexes
#
#  index_pages_on_digest                 (digest)
#  index_pages_on_website_id_and_status  (website_id,status)
#

class Page < ApplicationRecord
  # Helper scopes for testing/debugging purposes
  scope :containing_html5_video, -> { where("content ILIKE '%<video%'") }
  scope :containing_vimeo, -> { where("content ~* '<iframe.*?src.*?player.vimeo.com.*?>.*?</iframe>'") }
  scope :containing_youtube, -> { where("content ~* '<iframe.*?src.*?youtube.com/embed.*?>.*?</iframe>'") }
  scope :containing_jwplayer, -> { where("content ~* 'jwplayer\\('") }

  enum status: [
    :uncrawled,
    :crawling,
    :crawled,
    :processing,
    :processed,
    :crawl_error,
    :unknown_type_error,
    :skipped
  ]

  scope :visited,  -> { where(status: [:skipped, :crawl_error, :crawled]) }
  scope :not_visited, -> { where(status: [:uncrawled, :crawling]) }

  belongs_to :website
  has_many :videos

  #
  # Generate a SHA1 digest whenever the URL is changed
  #
  def url=(value)
    write_attribute(:url, value)

    self.digest = Digest::SHA1.hexdigest value
  end
end
