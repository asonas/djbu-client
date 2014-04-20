require "json"
require "net/http"
require "idobata"
require "taglib-ruby"

Idobata.hook_url = "https://idobata.io/hook/d6431e97-cf9e-4983-a66b-ae83b892bdce"
end_point = "http://djbu.ason.as/music"

uri = URI.parse(end_point)
json = JSON.parse(Net::HTTP.get(uri))

return false unless json['url']

base_path  = "/home/asonas/djbu-client/music"

options = "-o '#{base_path}/%(extractor)s/%(uploader)s/%(title)s.%(ext)s' --write-thumbnail --write-description --write-info-json"
Idobata::Message.create(source: "Downloading #{json['url']}", label: { type: :warning, text: "djbu-client" })
result = `youtube-dl #{options} #{json['url']}`.split("\n")
last = result.pop
result << last.gsub("[K", "").split("\r\e").uniq
Idobata::Message.create(source: result.join("<br />"), label: { type: :success, text: "djbu-client" })

last_directory = `ls -t /home/asonas/djbu-client/music/soundcloud`.split("\n").first
last_directory_path = "#{base_path}/soundcloud/#{last_directory}"

cover_art = `find #{last_directory_path} -name "*jpg"`.gsub("\n", "")
music = `find #{last_directory_path} -name "*mp3"`.gsub("\n", "")

picture_data = open(cover_art).read

TagLib::MPEG::File.open(music) do |file|
  tag = file.id3v2_tag

  pic = TagLib::ID3v2::AttachedPictureFrame.new
  pic.picture = picture_data
  pic.mime_type = "image/jpeg"
  pic.type = TagLib::ID3v2::AttachedPictureFrame::FrontCover

  tag.add_frame(pic)
  file.save
end
