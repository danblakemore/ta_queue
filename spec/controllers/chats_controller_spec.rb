require 'spec_helper'

describe ChatsController do

  describe "GET 'receive'" do
    it "returns http success" do
      get 'receive'
      response.should be_success
    end
  end

end
