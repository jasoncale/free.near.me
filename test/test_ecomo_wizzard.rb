require 'test_helper'

class EcomoWizzardTest < Test::Unit::TestCase
  
  context "EcomoWizzard" do
    context "getting the index" do
      setup do
        visit "/"
      end
      
      should "respond" do
        assert_contain("Hello!")
      end
    end
  end
      
end