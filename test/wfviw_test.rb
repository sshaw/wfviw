require File.expand_path '../test_helper.rb', __FILE__

class WFVIWTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_homepage
    get '/'
    assert last_response.ok?
    assert_match "WFVIW!?", last_response.body
  end

  def test_no_deployments
    get '/'
    assert last_response.ok?
    assert_match "Nothing has been deployed", last_response.body
  end

  def test_deployment_post
    post("/deploy?environment=Labs&name=cms&version=215.3")
    assert_equal 0, last_response.headers['Content-Length'].to_i
    assert_equal 201, last_response.status

    get '/'
    assert_match "Labs", last_response.body
    assert_match "cms", last_response.body
    assert_match "215.3", last_response.body
    DB << "delete from deployments" << "delete from environments"
  end
end
