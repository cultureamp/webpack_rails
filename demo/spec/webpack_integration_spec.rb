require 'rails_helper'

RSpec.describe "webpack bundle", :type => :request do
  it "builds successfully" do
    get "/assets/posts.js"

    expect(response.body).to include('PostsScreen')
  end
end