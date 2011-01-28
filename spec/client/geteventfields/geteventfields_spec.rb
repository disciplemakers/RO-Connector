require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "GetEventFields" do
  describe "without credentials" do
    it "shouldn't instantiate" do
      lambda { roc_get_event_fields = RegonlineConnector::Client::GetEventFields.new }.should raise_exception(ArgumentError)
    end
  end
  
  describe "with any credentials" do
    before(:each) do
      mock_WSDLDriverFactory = mock('WSDLDriverFactory')
      mock_RPCDriver = mock('Driver')
      mock_WSDLDriverFactory.should_receive(:create_rpc_driver).and_return(mock_RPCDriver)
      SOAP::WSDLDriverFactory.should_receive(:new).with('http://www.regonline.com/webservices/getEventFields.asmx?WSDL').and_return(mock_WSDLDriverFactory)
      @roc_gef = RegonlineConnector::Client::GetEventFields.new(100, 'joeuser', 'password', 'false')
    end
    
    it "should not give read access to account_id" do
      lambda { @roc_gef.account_id }.should raise_exception(NoMethodError)
    end
    
    it "should not give read access to username" do
      lambda { @roc_gef.username }.should raise_exception(NoMethodError)
    end
    
    it "should not give read access to password" do
      lambda { @roc_gef.password }.should raise_exception(NoMethodError)
    end
    
    it "should not give write access to account_id" do
      lambda { @roc_gef.account_id=200 }.should raise_exception(NoMethodError)
    end
    
    it "should not give write access to username" do
      lambda { @roc_gef.username='joeuser' }.should raise_exception(NoMethodError)
    end
    
    it "should not give write access to password" do
      lambda { @roc_gef.password='password' }.should raise_exception(NoMethodError)
    end
  end
  
  describe "with valid credentials" do
    before(:each) do
      @xml = "<fields><fees /><agendaItems><agendaItem id=\"777\" " +
             "name=\"Agenda 777\" /></agendaItems><customFields><customField " +
             "id=\"1925456\" name=\"Special Needs\" /></customFields></fields>"
      mock_WSDLDriverFactory = mock('SOAPWSDLDriverFactory')
      mock_RPCDriver = mock('SOAPRPCDriver')
      mock_MappingObject = mock('SOAPMappingObject')
      mock_MappingObject.stub(:retrieveEventFields2Result).and_return(@xml)
      mock_RPCDriver.stub(:RetrieveEventFields2).with(
                                    {"eventID"        => 100,
                                     "login"          => 'joeuser',
                                     "password"       => 'password',
                                     "excludeAmounts" => 'false'}
                                     ).and_return(mock_MappingObject)
      mock_WSDLDriverFactory.should_receive(:create_rpc_driver).and_return(mock_RPCDriver)
      SOAP::WSDLDriverFactory.should_receive(:new).with(
              'http://www.regonline.com/webservices/getEventFields.asmx?WSDL'
              ).and_return(mock_WSDLDriverFactory)
      @roc_gef = RegonlineConnector::Client::GetEventFields.new(100, 'joeuser', 'password', 'false')
    end
    
    it "should respond to RetrieveEventFields2" do
      @roc_gef.should respond_to(:RetrieveEventFields2)
    end
     
    it "should return XML when RetreiveEventFields2 is called" do
      @roc_gef.RetrieveEventFields2.should == @xml
    end
  end
  
  describe "with invalid credentials" do
    before(:each) do
      mock_WSDLDriverFactory = mock('SOAPWSDLDriverFactory')
      mock_RPCDriver = mock('SOAPRPCDriver')
      mock_RPCDriver.stub(:RetrieveEventFields2).with(
                                    {"eventID"        => 100,
                                     "login"          => 'joeuser',
                                     "password"       => 'bad_password',
                                     "excludeAmounts" => 'false'}
                                     ).and_raise(SOAP::FaultError.new(
                                          SOAP::SOAPFault.new(SOAP::SOAPString.new('Server'),
                                                              SOAP::SOAPString.new('Authentication failure'))))
      mock_RPCDriver.stub(:RetrieveEventFields2).with(
                              {"eventID"        => 999,
                               "login"          => 'joeuser',
                               "password"       => 'password',
                               "excludeAmounts" => 'false'}
                               ).and_raise(SOAP::FaultError.new(
                                    SOAP::SOAPFault.new(SOAP::SOAPString.new('Server'),
                                                        SOAP::SOAPString.new('Object reference not set to an instance of an object.'))))
      mock_WSDLDriverFactory.should_receive(:create_rpc_driver).and_return(mock_RPCDriver)
      SOAP::WSDLDriverFactory.should_receive(:new).with(
              'http://www.regonline.com/webservices/getEventFields.asmx?WSDL'
              ).and_return(mock_WSDLDriverFactory)
    end
    
    it "should raise a SOAP fault error with bad password" do 
      roc_gef = RegonlineConnector::Client::GetEventFields.new(100, 'joeuser', 'bad_password', 'false')
      lambda { roc_gef.RetrieveEventFields2 }.should raise_exception(SOAP::FaultError)
    end
    
    it "should raise a SOAP fault error with any bad event id" do
      roc_gef = RegonlineConnector::Client::GetEventFields.new(999, 'joeuser', 'password', 'false') 
      lambda { roc_gef.RetrieveEventFields2 }.should raise_exception(SOAP::FaultError)
    end
  end
  
end