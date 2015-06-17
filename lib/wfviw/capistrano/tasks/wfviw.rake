require "wfviw/capistrano/strategy"
require "net/http"

namespace :wfviw do
  desc "Track a deployment"
  task :deploy do

    set :git_strategy, WFVIW::Capistrano::Strategy::Git
    set :hg_strategy,  WFVIW::Capistrano::Strategy::Hg

    on fetch(:wfviw_roles, release_roles(:all)) do
      within repo_path do
        data = {
          :name        => ENV["NAME"]        || fetch(:application)
          :version     => ENV["VERSION"]     || strategy.release_version
          :environment => ENV["ENVIRONMENT"] || fetch(:stage) # fetch(:rails_env)
        }

        #http.use_ssl = true
        #http.ssl_version = options[:ssl_version] || 'TLSv1'

        req = Net::HTTP::Delete.new("/deploy")
        req.set_form_data(data)

        host = fetch(:wfviw_host)
        port = fetch(:wfviw_port)
        # if host...
        # if version...

        http = Net::HTTP.new(host)
        http.request(req)
      end
    end
  end
end
