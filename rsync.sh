rsync --checksum -av /home/asonas/app/djbu-client/music/ /var/www/namanas/files
curl -d token=$SLACK_TOKEN -d channel=C0298QA7Q -d text="<@U0298QA7J|asonas> <@U02AW6EBQ|namamana> Successful syncronization. http://namanas.ason.as/" -d username=asoNAS https://slack.com/api/chat.postMessage
