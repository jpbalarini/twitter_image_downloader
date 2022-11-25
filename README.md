# Twitter feed downloader

This Ruby script lets you download your Twitter's feed images.

# How to run it

1. Make sure you have ruby and the [WebP library](https://developers.google.com/speed/webp/docs/precompiled) installed in your machine
2. Create a Twitter app and enable the `User authentication` section
3. Set an ENV variable with your app's client id. If you set your app to be a confidential client, you will also need to configure the `CLIENT_SECRET` (or set it to Public client instead)
	```bash
	export CLIENT_ID='your-client-id'
	```
4. Install gems
	```
	bundle install
	```
5. Run the script
	```bash
	ruby twitter_image_downloader.rb
	```
6. All images will be downloaded to the `./images` folder