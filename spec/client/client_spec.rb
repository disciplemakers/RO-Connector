require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Client" do
  describe "without credentials" do
    it "shouldn't instantiate" do
      lambda { roc_client = RegonlineConnector::Client.new }.should raise_exception(ArgumentError)
    end
  end
  
  
  describe "with any credentials" do
    before(:each) do
      @roc = RegonlineConnector::Client.new(100, 'joeuser', 'password')
    end
    
    it "should return xml when given zipped response" do
      response = "UEsDBC0AAAAIAIxzQT7ZYsmd//////////8EABQAZGF0YQEAEACoAwAAAAAA" +
                 "AGUBAAAAAAAAfZPdTsJQEITnUXgCESEak5PGH270whh/LrxEKUIshVQI8PZ+" +
                 "c2ppapE0HNru7szs7DboSak+NdO3Vio04pxpoVyJgm54zvjl+iBrqDVnolMi" +
                 "3X9iQc8gGGUNYqLbiDUBs9Cc6nGsbeYEsiqODBZXp+rAYQ2umuudswBxCtJS" +
                 "d2RV8YLIIf3OSdRHbV8DzoEudB7Zj1eEyDeCJ9M1esfwpjC7m1Rb1M1RkHF/" +
                 "9ef5BJcWRO2ONR/GCFQb0Z5s912UDnkGD5HBPt+DNsV74x2K25tZVGg1VV3l" +
                 "i+fWxBuCl0a0diyQu4alqcq7sIq9Vqhlh0uwc+326kcNn3po7+kM3zs4WOZ5" +
                 "4u465d/9tCsC7pltR/UbStfkd/TC3ebXgzoeIpanXm7qK3lGrSZb7e+SuD3w" +
                 "FnsTx/AnutxfrjmcYzXWkEfddacb3hb60iOTMUu9p372rrYjE/jrSftLyrja" +
                 "ed0j3+IPUEsBAi0ALQAAAAgAjHNBPtliyZ3//////////wQAFAAAAAAAAAAA" +
                 "AAAAAAAAAGRhdGEBABAAqAMAAAAAAABlAQAAAAAAAFBLBQYAAAAAAQABAEYA" +
                 "AACbAQAAAAAAAAAAAAAAAAA="
      xml = "<?xml version=\"1.0\" encoding=\"utf-8\"?><string " +
            "xmlns=\"http://www.regonline.com/webservices/\"><Registration>" +
            "<BalanceDue>0</BalanceDue><Status>Confirmed</Status><CancelDate />" +
            "<membershipID /><registrationID>30340476</registrationID>" +
            "<emailAddress>example@example.com</emailAddress><prefix />" +
            "<firstName>John</firstName><middleName /><lastName>Doe</lastName>" +
            "<suffix /><title /><company /><address1>123 Any Street</address1>" +
            "<city>Your Town</city><region>UT</region>" +
            "<postalCode>99999</postalCode><country /><workPhone /><homePhone />" +
            "<fax /><cellPhone /></Registration></string>" 

      RegonlineConnector::Client.zip_to_xml(response).should == xml
    end
    
    it "should not give read access to account_id" do
      lambda { @roc.account_id }.should raise_exception(NoMethodError)
    end
    
    it "should not give read access to username" do
      lambda { @roc.username }.should raise_exception(NoMethodError)
    end
    
    it "should not give read access to password" do
      lambda { @roc.password }.should raise_exception(NoMethodError)
    end
    
    it "should not give write access to account_id" do
      lambda { @roc.account_id=200 }.should raise_exception(NoMethodError)
    end
    
    it "should not give write access to username" do
      lambda { @roc.username='joeuser' }.should raise_exception(NoMethodError)
    end
    
    it "should not give write access to password" do
      lambda { @roc.password='password' }.should raise_exception(NoMethodError)
    end
  end
end
