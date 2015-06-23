require "uri"
require "net/http"

require_relative "../wfviw/strategy"

namespace :wfviw do
  desc "Add a deployment to WFVIW!?"
  task :deploy do

    set :git_strategy, WFVIW::Capistrano::Strategy::Git
    set :hg_strategy,  WFVIW::Capistrano::Strategy::Hg
    set :svn_strategy,  WFVIW::Capistrano::Strategy::Svn

    on fetch(:wfviw_roles, release_roles(:all)) do
      within repo_path do
        data = {
          :name        => ENV["NAME"]        || fetch(:application),
          :version     => ENV["VERSION"]     || strategy.release_version,
          :environment => ENV["ENVIRONMENT"] || fetch(:stage),
          :deployed_by => ENV["USER"]
        }

        uri = fetch(:wfviw_server)
        if uri.nil?
          error "Cannot add deployment to WFVIW!?, :wfviw_server is not set"
          next
        end

        uri = URI(uri)
        uri = URI("http://#{uri}") if uri.is_a?(URI::Generic)

        # Just for training slash
        uri.normalize!
        uri.path = "deploy" if uri.path == "/"

        info "Creating WFVIW!? deployment at #{uri}"

        Net::HTTP.post_form(uri, data)
      end
    end
  end

  after "deploy:finished", "wfviw:deploy"
end
