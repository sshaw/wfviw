require './wfviw'

use Rack::Auth::Basic, "Restricted Area" do |username, password|
    [username, password] == ['admin', 'admin']
end

run Sinatra::Application
