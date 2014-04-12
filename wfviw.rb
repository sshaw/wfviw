require "sinatra"
require "sequel"
require "sequel/extensions/core_extensions" # for lit()
require "json"
require "dotenv"

Dotenv.load

DB = Sequel.connect( ENV['DATABASE_URL'] || "sqlite://deployments.db")
DB.create_table? :environments do
  String :name, :null => false, :unique => true
  primary_key :id
end

DB.create_table? :deployments do
  String :name, :null => false, :index => true
  String :version, :null => false
  String :hostname
  String :deployed_by
  Time   :deployed_at, :null => false

  primary_key :id
  foreign_key :environment_id, :environments, :null => false
end

class Deployment < Sequel::Model
  many_to_one :environment

  dataset_module do
    def latest
      eager(:environment).select(:id, :name, :version, :environment_id, :deployed_at).order(:environment_id, :name)
    end
  end
end

class Environment < Sequel::Model
  one_to_many :deployments
end

class DeployManager
  class << self
    def latest(q = {})
      env = q["env"].to_i
      rs = Deployment.latest
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
        Deployment.where(:environment_id => env[:id], :name => attrs["name"] ).delete
        Deployment.create(attrs.merge(:environment => env, :deployed_at => Time.now))
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
  redirect to("/")
end

post "/deploy" do
  DeployManager.create(params)
  201
end

get "/" do
  @deploys      = DeployManager.latest(params)
  @environments = DeployManager.environments
  erb :index
end
