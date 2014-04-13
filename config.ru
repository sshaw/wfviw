require './wfviw'

if ENV['RACK_ENV'] == "production"
  use Rack::Auth::Basic, "Restricted Area" do |username, password|
    [username, password] == [ENV['USER'], ENV['PASSWORD']]
  end
end

run Sinatra::Application
