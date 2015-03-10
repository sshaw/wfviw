require "sinatra"
require "sequel"
require "sequel/extensions/core_extensions" # for lit()
require "json"

VERSION = "0.0.2"

DB = Sequel.connect(ARGV.shift || ENV["DATABASE_URL"] || "sqlite://deployments.db")
DB.create_table? :environments do
  String :name, :null => false, :unique => true
  primary_key :id
end

DB.create_table? :deployments do
  String :name, :null => false, :index => true
  String :version, :null => false
  String :hostname
  String :deployed_by
  Time   :deployed_at, :null => false, :default => "datetime('now', 'localtime')".lit

  primary_key :id
  foreign_key :environment_id, :environments, :null => false
end

class Deployment < Sequel::Model
  many_to_one :environment
end

class Environment < Sequel::Model
  one_to_many :deployments
end

class DeployManager
  class << self
    def version(q = {})
      env = q["env"].to_i
      rs = Deployment
      rs = rs.where(:environment_id => env) if env > 0
      rs.all
    end

    def list(q = {})
      q = q.dup
      page = q.delete(:page).to_i
      page = 1  unless page > 0

      size = q.delete(:size).to_i
      size = 10 unless size > 0

      # order...
      Deployment.where(q).limit(size * page, page - 1)
    end

    def delete(id)
      Deployment.where(:id => id).delete
    end

    def create(attrs)
      attrs = attrs.dup
      Deployment.db.transaction do
        env = Environment.find_or_create(:name => attrs.delete("environment"))
        Deployment.create(attrs.merge(:environment => env))
      end
    end

    def environments
      Environment.all
    end
  end
end

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

post "/deploy/:id/delete" do
  DeployManager.delete(params[:id])
  #redirect to("/")
  200
end

post "/deploy" do
  DeployManager.create(params)
  201
end

get "/" do
  #TODO - Make sure this gels with the refactered version method above.
  @deploys      = DeployManager.version(params)
  @environments = DeployManager.environments
  erb :index
end
