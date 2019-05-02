require 'csv'

module VideoService
  class << self
    def find_videos(html)
      videos = []

      video_parsers.each do |parser|
        chunks = parser.parse(html)

        chunks.each do |chunk|
          video = Video.new
          video.url =  chunk[:src]
          video.embed_type = chunk[:type]
          video.fragment = chunk[:fragment]
          video.captioned = chunk[:tracks]
          video.properties = chunk[:properties]

          videos << video
        end
      end

      return videos
    end

    def get_csv(website:)
      result = CSV.generate do |csv|
        csv << ["id", "pid", "page title", "page url", "embed_type", "view_count", "video_source", "properties", "tracks"]

        website.videos.order(page_id: :asc).each do |v|
          csv << [v.id, v.page_id, v.page_title, v.page_url, v.embed_type, v.view_count, v.url, v.properties, v.captioned? ? true : ""]
        end
      end

      result
    end

    private

    def video_parsers
      [
        HTML5VideoParser,
        YoutubeVideoParser,
        VimeoVideoParser,
        JWPlayerVideoParser,
        OpenCoursewareVideoParser
      ]
    end
  end
end