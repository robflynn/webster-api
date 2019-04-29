class YoutubeVideoParser < VideoParser
  def self.parse(html)
    videos = []

    doc = Nokogiri::HTML(html)

    iframes = doc.css('iframe')

    iframes.each do |iframe|
      src = iframe.attr('src')

      if /youtube.com\/embed.*?/ =~ src

        parsed_uri = URI(src)
        parsed_uri.query = nil

        video = {
          src: parsed_uri.to_s,
          type: 'youtube',
          fragment: iframe.to_html,
          properties: '',
          tracks: false
        }

        videos << video
      end
    end

    return videos
  end
end