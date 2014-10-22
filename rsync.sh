rsync --checksum -av /home/asonas/djbu-client/music/ amanusa:/var/www/namanas/files
curl -d token=$SLACK_TOKEN -d channel=C0298QA7Q -d text="@asonas @namamana Successful syncronization. http://namanas.ason.as/" -d username=asoNAS https://slack.com/api/chat.postMessage
