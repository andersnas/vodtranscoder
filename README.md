# VOD transcoder

This project holds some scripts that will help in achieving distributed VOD transcoding on Linode using Terraform. This is by no means meant for real production transcoding, but rather a way to test this concept and evaluate results. There is also a longer piece on this here: https://www.linkedin.com/pulse/scaling-open-source-vod-transcoding-taming-swarm-bees-anders-n%C3%A4sman

You need these pre requisites:

1. A Linode account
  - An Linode API key
3. A Linode object storage bucket with:
  - A directory called intake
  - A directory called output
  - Applicable secrets to access it.
3. A Linode machine (16GB Dedicated) with the following
  - Mapped the Object storage bucket as /mnt/transcoding
  - Installed Terraform
  - Installed ffmpeg
  - A directory with the scripts in this repository

Configure all settings in config.cfg file + add your Linode API key in the transcodernode.tf file.

Flow:

1. Put a media file in the /mnt/transcoding/intake folder.
2. cd to the directory holding the scripts from this repository
3. Make sure the scripts have execute rights (chmod +x *.sh)
4. Run ./transcode /mnt/transcoding/intake/YOUR_MEDIA_FILE 10
5. Watch the script running and the machine being spun up and down.
6. Check /mnt/output for the transcoded files.
