require 'rails_helper'

RSpec.describe "Verses", :type => :request do
  describe "GET /api/verses" do
    it "response has a 200 OK status" do
      get api_verses_path
      expect(response.status).to be(200)
    end
  end
end