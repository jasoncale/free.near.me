require 'test_helper'

class RemoteListings::ReyoozTest < Test::Unit::TestCase

  context "Reyooz" do
    setup do
      
      @items = [
        {"item"=>{
          "expires_at"=>"2010-02-05 13:59:03", 
          "created_at"=>"2009-02-28 10:31:31", 
          "title"=>"1 double bed, 1 double mattress & 2 sofa's", 
          "updated_at"=>"2009-03-15 02:55:36", 
          "id"=>"61", 
          "lng"=>"-0.144543", 
          "user_id"=>"117", 
          "description"=>"The Bed(including mattress that is like 100% new) The bed is near new (approx 1 year old). The bed is a 'box string inner-sprung base' - light blue in colour.\r\n\r\nSole double Mattress\r\n \r\nThe sofas:\r\n\r\nSofas are in ok/good condition. Both two seaters with a light blue pattern. There's a rip in one of the cushions - but don't worry - we have dark brown couch covers to include with the couches. \r\n\r\nOne of the couches also folds out to a double bed!\r\n\r\nBed & sofas are PICK UP ONLY and ready to go IMMEDIATELY.\r\n\r\nPlease call Kristen on 07 990 600 397. Photos of the above can be sent to you if required.\r\n", 
          "lat"=>"51.451839"
          }
        }
      ]
      
      #RemoteListings::Reyooz.expects(:lookup).at_least_once.with("sofa", {}).returns(@items)
      
      @latest = RemoteListings::Reyooz.lookup("sofa", {})
    end

    should "have items" do
      assert @latest.present?
    end
    
    should "have return right amount of items item" do
      assert_equal(@items.size, @latest.size)
    end
    
    should "have correct data" do
      assert_equal(@latest.first["item"]["title"], "1 double bed, 1 double mattress & 2 sofa's")
    end
    
    context "Item.search" do
      setup do
        @search = Item.search(:q => "sofa")
      end

      should "contain reyooz results" do
        assert_equal(@search.first.title, "1 double bed, 1 double mattress & 2 sofa's")
      end
    end
    
    
    #should_change "Item.count", :by => 20
    
  end
  

end