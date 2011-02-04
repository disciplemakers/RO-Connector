require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "GetEvents" do
  describe "without credentials" do
    it "shouldn't instantiate" do
      lambda { roc_get_events = RegonlineConnector::Client::GetEvents.new }.should raise_exception(ArgumentError)
    end
  end
  
  describe "with any credentials" do
    before(:each) do
      mock_WSDLDriverFactory = mock('WSDLDriverFactory')
      mock_RPCDriver = mock('Driver')
      mock_WSDLDriverFactory.should_receive(:create_rpc_driver).and_return(mock_RPCDriver)
      SOAP::WSDLDriverFactory.should_receive(:new).with('http://www.regonline.com/webservices/getEvents.asmx?WSDL').and_return(mock_WSDLDriverFactory)
      @roc_ge = RegonlineConnector::Client::GetEvents.new(100, 'joeuser', 'password')
    end
    
    it "should not give read access to account_id" do
      lambda { @roc_ge.account_id }.should raise_exception(NoMethodError)
    end
    
    it "should not give read access to username" do
      lambda { @roc_ge.username }.should raise_exception(NoMethodError)
    end
    
    it "should not give read access to password" do
      lambda { @roc_ge.password }.should raise_exception(NoMethodError)
    end
    
    it "should not give write access to account_id" do
      lambda { @roc_ge.account_id=200 }.should raise_exception(NoMethodError)
    end
    
    it "should not give write access to username" do
      lambda { @roc_ge.username='joeuser' }.should raise_exception(NoMethodError)
    end
    
    it "should not give write access to password" do
      lambda { @roc_ge.password='password' }.should raise_exception(NoMethodError)
    end
  end
  
  describe "with valid credentials" do
    before(:each) do
      @xml = "<NewDataSet>\n  <Table>\n    <ID>999999</ID>\n    " +
             "<Status>Testing</Status>\n    <Type>Event</Type>\n    " +
             "<ClientID />\n    <Title>Test Conference</Title>\n    " +
             "<Description />\n    <StartDate>2010-10-29T18:30:00-06:00" +
             "</StartDate>\n    <EndDate>2010-10-31T14:00:00-06:00</EndDate>\n" +
             "    <LocationName>Conference Center</LocationName>\n    <Room />\n" +
             "    <Building />\n    <Address1>123 Main Street</Address1>\n" +
             "    <Address2 />\n    <City>Yourtown</City>\n    " +
             "<Region>Pennsylvania</Region>\n    <Country />\n    " +
             "<PostalCode>12345-6789</PostalCode>\n    <Capacity>0</Capacity>\n    " +
             "<Total>14</Total>\n    <Cancelled>2</Cancelled>\n    " +
             "<Substitutions>0</Substitutions>\n    <Revenue>123.0000</Revenue>\n" +
             "    <Payments>-432.0000</Payments>\n    <Keywords />\n    " +
             "<EventFeeAmount>0.0000</EventFeeAmount>\n    " +
             "<add_date>2010-05-18T08:37:50.347-06:00</add_date>\n    " +
             "<mod_date>2011-01-25T09:08:40.01-07:00</mod_date>\n  </Table>\n" +
             "</NewDataSet>"
      @filter_xml = "<filters><Loc_Name>Yourtown</Loc_Name><Type_Id>1</Type_Id></filters>"

      mock_WSDLDriverFactory = mock('SOAPWSDLDriverFactory')
      mock_RPCDriver = mock('SOAPRPCDriver')
      mock_MappingObject = mock('SOAPMappingObject')
      mock_MappingObject.stub(:byAccountIDResult).and_return(@xml)
      mock_MappingObject.stub(:byAccountIDEventIDResult).and_return(@xml)
      mock_MappingObject.stub(:byAccountIDWithFiltersResult).and_return(@xml)
      mock_RPCDriver.stub(:ByAccountID).with({"AccountID" => 100,
                                              "Username"  => 'joeuser',
                                              "Password"  => 'password'}
                                             ).and_return(mock_MappingObject)
      mock_RPCDriver.stub(:ByAccountIDEventID).with({"AccountID" => 100,
                                               "Username"  => 'joeuser',
                                               "Password"  => 'password',
                                               "EventId"   => 999999}
                                             ).and_return(mock_MappingObject)
      mock_RPCDriver.stub(:ByAccountIDWithFilters).with({"AccountID"      => 100,
                                                         "Username"       => 'joeuser',
                                                         "Password"       => 'password',
                                                         "xmlFilterData"  => @filter_xml,
                                                         "FilterOperator" => 'and',
                                                         "LikeMatching"   => 'true'}
                                             ).and_return(mock_MappingObject)
      mock_WSDLDriverFactory.should_receive(:create_rpc_driver).and_return(mock_RPCDriver)
      SOAP::WSDLDriverFactory.should_receive(:new).with(
              'http://www.regonline.com/webservices/getEvents.asmx?WSDL'
              ).and_return(mock_WSDLDriverFactory)
      @roc_ge = RegonlineConnector::Client::GetEvents.new(100, 'joeuser', 'password')
    end

    it "should return XML when ByAccountID is called" do
      @roc_ge.ByAccountID.should == @xml
    end
    
    it "should return XML when ByAccountIDEventID is called" do
      @roc_ge.ByAccountIDEventID(999999).should == @xml
    end
    
    it "should show ByAccountIDWithFilters as not implemented" do
      @roc_ge.ByAccountIDWithFilters(@filter_xml, 'and', 'true').should == @xml
    end
    
    it "should successfully authenticate" do
      @roc_ge.Authenticate.should be_true
    end
  end
  
  describe "with invalid credentials" do
    before(:each) do
      @xml = "The credentials you supplied are not valid."

      mock_WSDLDriverFactory = mock('SOAPWSDLDriverFactory')
      mock_RPCDriver = mock('SOAPRPCDriver')
      mock_MappingObject = mock('SOAPMappingObject')
      mock_MappingObject.stub(:byAccountIDResult).and_return(@xml)
      mock_MappingObject.stub(:byAccountIDEventIDResult).and_return(@xml)
      mock_MappingObject.stub(:byAccountIDWithFiltersResult).and_return(@xml)
      mock_RPCDriver.stub(:ByAccountID).with({"AccountID" => 100,
                                              "Username"  => 'joeuser',
                                              "Password"  => 'bad_password'}
                                             ).and_return(mock_MappingObject)
      mock_RPCDriver.stub(:ByAccountIDEventID).with({"AccountID" => 100,
                                               "Username"  => 'joeuser',
                                               "Password"  => 'bad_password',
                                               "EventId"   => 999999}
                                             ).and_return(mock_MappingObject)
      mock_RPCDriver.stub(:ByAccountIDWithFilters).with({"AccountID"      => 100,
                                                         "Username"       => 'joeuser',
                                                         "Password"       => 'bad_password',
                                                         "xmlFilterData"  => @filter_xml,
                                                         "FilterOperator" => 'and',
                                                         "LikeMatching"   => 'true'}
                                             ).and_return(mock_MappingObject)
      mock_WSDLDriverFactory.should_receive(:create_rpc_driver).and_return(mock_RPCDriver)
      SOAP::WSDLDriverFactory.should_receive(:new).with(
              'http://www.regonline.com/webservices/getEvents.asmx?WSDL'
              ).and_return(mock_WSDLDriverFactory)
      @roc_ge = RegonlineConnector::Client::GetEvents.new(100, 'joeuser', 'bad_password')
    end
    
    it "ByAccountID should still return xml invalid credentials message with bad password" do
      @roc_ge.ByAccountID.should == @xml
    end
    
    it "ByAccountIDEventID should still return xml invalid credentials message with bad password" do
      @roc_ge.ByAccountIDEventID(999999).should == @xml
    end
    
    it "ByAccountIDWithFilters should still return xml invalid credentials message with bad password" do
      @roc_ge.ByAccountIDWithFilters(@filter_xml, 'and', 'true').should == @xml
    end
    
    it "should not successfully authenticate" do
      @roc_ge.Authenticate.should be_false
    end
  end
  
end