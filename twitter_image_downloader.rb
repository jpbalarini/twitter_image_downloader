require 'down'
require 'fileutils'
require 'json'
require 'twitter_oauth2'
require 'typhoeus'

MAX_RESULTS = 100
IMAGES_DIRECTORY = './images'
# Replace the following URL with your callback URL, which can be obtained from your App's auth settings.
REDIRECT_URI = 'http://localhost:3000'

# First, you will need to enable OAuth 2.0 in your App’s auth settings in the Developer Portal to get your client ID.
# Inside your terminal you will need to set an enviornment variable
# export CLIENT_ID='your-client-id'
client_id = ENV['CLIENT_ID']

# If you have selected a type of App that is a confidential client you will need to set a client secret.
# Confidential Clients securely authenticate with the authorization server.

# Inside your terminal you will need to set an enviornment variable
# export CLIENT_SECRET='your-client-secret'

# Remove the comment on the following line if you are using a confidential client
client_secret = ENV["CLIENT_SECRET"]


# Make a request to the users/me endpoint to get your user ID
def users_me(token_response)
  url = 'https://api.twitter.com/2/users/me'
  options = {
    method: 'get',
    headers: {
      'User-Agent': 'ReverseChronHomeTimelineSampleCode',
      'Authorization': "Bearer #{token_response}"
    },
  }

  request = Typhoeus::Request.new(url, options)
  response = request.run
end

def reverse_chron_timeline(user_id, token_response)
  # Make a request to the reverse chronological home timeline endpoint
  url = "https://api.twitter.com/2/users/#{user_id}/timelines/reverse_chronological"

  # Add or remove parameters below to adjust the query and response fields within the payload
  # See docs for list of param options: 
  # https://developer.twitter.com/en/docs/twitter-api/tweets/timelines/api-reference/get-users-id-reverse-chronological
  query_params = {
    'max_results' => MAX_RESULTS,
    'expansions' => 'attachments.media_keys,author_id',
    'tweet.fields' => 'attachments,author_id,conversation_id,created_at,entities,id,lang',
    'user.fields' => 'username',
    'media.fields' => 'url,preview_image_url,type,variants'
  }

  options = {
    method: 'get',
    headers: {
      "User-Agent": "ReverseChronTimelinesSampleCode",
      "Authorization": "Bearer #{token_response}"
    },
    params: query_params
  }

  request = Typhoeus::Request.new(url, options)
  response = request.run
end

def fetch_token(client)
  # Create your authorization url
  authorization_url = client.authorization_uri(
    # Update scopes if needed
    scope: [
      :'users.read',
      :'tweet.read',
      :'offline.access'
    ]
  )

  # Set code verifier and state
  code_verifier = client.code_verifier

  # Visit the URL to authorize your App to make requests on behalf of a user
  print 'Visit the following URL to authorize your App on behalf of your Twitter handle in a browser'
  puts authorization_url
  `open "#{authorization_url}"`

  print 'Paste in the full URL after you authorized your App: ' and STDOUT.flush

  # Fetch your access token
  full_text = gets.chop
  new_code = full_text.split('code=')
  code = new_code[1]
  client.authorization_code = code

  # Your access token
  token_response = client.access_token! code_verifier
end

if client_secret.nil?
  # Start an OAuth 2.0 session with a public client
  client = TwitterOAuth2::Client.new(
    identifier: "#{client_id}",
    redirect_uri: "#{REDIRECT_URI}"
  )
else
  # Start an OAuth 2.0 session with a confidential client
  client = TwitterOAuth2::Client.new(
    identifier: "#{client_id}",
    secret: "#{client_secret}",
    redirect_uri: "#{REDIRECT_URI}"
  )
end

# Get user_id
token_response = fetch_token(client)
me_response = users_me(token_response)
me_body = JSON.parse(me_response.body)
user_id = me_body['data']['id']

# Get timeline for user_id
response_timeline = reverse_chron_timeline(user_id, token_response)
parsed_body = JSON.parse(response_timeline.body)

if response_timeline.code != 200
  puts "Bad response code: #{response_timeline.code}"
  return
end

# Obtain attached media urls
attached_media = parsed_body['includes']['media']
# puts JSON.pretty_generate(attached_media)
media_urls = attached_media.map { |media| media['url'] if media['type'] == 'photo' }
# Remove empty values
media_urls.compact!
puts "Found #{media_urls.count} attached images"

# Create output dir if not exists
unless File.directory?(IMAGES_DIRECTORY)
  FileUtils.mkdir_p(IMAGES_DIRECTORY)
end

# Download images
media_urls.each do |media_url|
  tempfile = Down.download(media_url)
  FileUtils.mv(tempfile.path, "#{IMAGES_DIRECTORY}/#{tempfile.original_filename}")
end

# Convert them to WebP
Dir.glob("#{IMAGES_DIRECTORY}/*.{jpeg,jpg,png}") do |image_path|
  image_name = File.basename(image_path, ".*")
  image_extension = File.extname(image_path)
  `cwebp -m 6 #{IMAGES_DIRECTORY}/#{image_name}#{image_extension} -o #{IMAGES_DIRECTORY}/#{image_name}.webp`
end
