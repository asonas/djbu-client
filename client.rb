require "json"
require "net/http"
require "idobata"

Idobata.hook_url = "https://idobata.io/hook/d6431e97-cf9e-4983-a66b-ae83b892bdce"
end_point = "http://djbu.ason.as/music"

uri = URI.parse(end_point)
json = JSON.parse(Net::HTTP.get(uri))

if json['url']
  options = "-o 'music/%(uploader)s/%(title)s.%(ext)s' --write-thumbnail --write-description --write-info-json"
  system "youtube-dl", options, json['url']
else
  puts "nothig queue"
end
