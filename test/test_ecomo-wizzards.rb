require 'test_helper'

class EcomoWizzardTest < Test::Unit::TestCase

  context "EcomoWizzard" do
    context "getting the index" do
      setup do
        get '/'
      end
      
      should "respond" do
        assert body
      end
    end
  end

end