require './wfviw'

use Rack::Auth::Basic, "Restricted Area" do |username, password|
    [username, password] == [ENV['USER'], ENV['PASSWORD']]
end

run Sinatra::Application
