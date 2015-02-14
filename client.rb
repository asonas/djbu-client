require "json"
require "net/http"
require "idobata"
require "taglib"

Idobata.hook_url = "https://idobata.io/hook/d6431e97-cf9e-4983-a66b-ae83b892bdce"
end_point = "http://djbu.ason.as/music"

uri = URI.parse(end_point)
json = JSON.parse(Net::HTTP.get(uri))

exit unless json['url']

base_path  = "/home/asonas/app/djbu-client/music"

options = "-o '#{base_path}/%(extractor)s/%(uploader)s/%(title)s.%(ext)s' --write-thumbnail --write-description --write-info-json"
Idobata::Message.create(source: "Downloading #{json['url']}", label: { type: :warning, text: "djbu-client" })
result = `youtube-dl #{options} "#{json['url']}"`.split("\n")
last = result.pop
result << last.gsub("[K", "").split("\r\e").uniq
Idobata::Message.create(source: result.join("<br />"), label: { type: :success, text: "djbu-client" })

last_directory = `ls -t #{base_path}/soundcloud`.split("\n").first
last_directory_path = "#{base_path}/soundcloud/#{last_directory}"

file_name = `youtube-dl --get-title "#{json['url']}"`.gsub("\n", "")
cover_art = "#{last_directory_path}/#{file_name}.jpg"
exit unless File.exists?(cover_art)
music = "#{last_directory_path}/#{file_name}.mp3"

text = "Downloaded #{file_name}"
`curl -d token=#{ENV['SLACK_TOKEN']} -d channel=C0298QA7Q -d text='#{text}' -d username=asoNAS https://slack.com/api/chat.postMessage`

track = JSON.parse(`youtube-dl --dump-json "#{json['url']}"`)

TagLib::MPEG::File.open(music) do |file|
  tag = file.id3v2_tag
  tag.artist = track['uploader']

  pic = TagLib::ID3v2::AttachedPictureFrame.new
  pic.picture = File.open(cover_art, 'rb') { |f| f.read }
  pic.mime_type = "image/jpeg"
  pic.type = TagLib::ID3v2::AttachedPictureFrame::FrontCover

  tag.add_frame(pic)
  file.save
end

`curl -F file="@#{music}" -F title='#{file_name}' -F channels=C0298QA7Q -F token=#{ENV['SLACK_TOKEN']} https://slack.com/api/files.upload`
`sh /home/asonas/app/djbu-client/rsync.sh`
