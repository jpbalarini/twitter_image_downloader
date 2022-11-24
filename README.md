# Twitter feed downloader

This Ruby script lets you download your Twitter's feed images.

# How to run it

1. Make sure you have ruby installed in your machine
2. Create a Twitter app and enable `User authentication`
3. Set an ENV variable with your app's client id
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