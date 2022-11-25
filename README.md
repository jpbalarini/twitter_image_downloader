# Twitter feed downloader

This quick and dirty Ruby script lets you download your Twitter feed images and convert them to the WebP image format.
Part of this [Twitter thread](https://twitter.com/jpbalarini/status/1595783126092873729).

# How to run it

1. Make sure you have ruby and the [WebP library](https://developers.google.com/speed/webp/docs/precompiled) installed in your machine
2. Create a Twitter app and enable the `User authentication` section
3. Set an ENV variable with your app's client id. If you set your app to be a `confidential client`, you will also need to configure the `CLIENT_SECRET` ENV variable (or set it to `public client` instead)
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