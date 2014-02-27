require "sinatra"
require "sequel"
require "json"

abort "No DB connection given" unless ARGV[0]

DB = Sequel.connect(ARGV[0])
DB.create_table? :environments do
  String :name, :null => false, :unique => true
  primary_key :id
end

DB.create_table? :deployments do
  String :name, :null => false, :index => true
  String :version, :null => false
  String :hostname
  String :deployed_by
  Time   :deployed_at  
  primary_key :id
  foreign_key :environment_id, :environments, :null => false
end

class Deployment < Sequel::Model
  many_to_one :environment

  dataset_module do
    def latest
      eager(:environment).order(:name).group_by(:environment_id).having { max(id) }
    end
  end
end

class Environment < Sequel::Model
  one_to_many :deployments
end

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

post "/deploy/:id/delete" do 
  Deployment.where(:id => params[:id]).delete
  redirect to("/")
end

post "/deploy" do
  #Enviornment.find_or_create(params.delete(:environment))
  #deploy = Deployment.insert(params)    
end

get "/" do 
  @deploys = Deployment.latest.all
  @environments = Environment.all
  erb :index
end
