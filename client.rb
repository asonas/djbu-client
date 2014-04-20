require "json"
require "net/http"
require "idobata"

Idobata.hook_url = "https://idobata.io/hook/d6431e97-cf9e-4983-a66b-ae83b892bdce"
end_point = "http://djbu.ason.as/music"

uri = URI.parse(end_point)
json = JSON.parse(Net::HTTP.get(uri))

if json['url']
  options = "-o '/home/asonas/djbu-client/music/%(extractor)s/%(uploader)s/%(title)s.%(ext)s' --write-thumbnail --write-description --write-info-json"
  Idobata::Message.create(source: "Downloading #{json['url']}", label: { type: :warning, text: "djbu-client" })
  result = `youtube-dl #{options} #{json['url']}`.split("\n")
  last = result.pop
  result << last.gsub("[K", "").split("\r\e").uniq
  Idobata::Message.create(source: result.join("<br />"), label: { type: :success, text: "djbu-client" })
end
