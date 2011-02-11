require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "RetrieveSingleRegistration" do
  describe "without credentials" do
    it "shouldn't instantiate" do
      lambda { roc_retrieve_single_registration = RegonlineConnector::Client::RetrieveSingleRegistration.new }.should raise_exception(ArgumentError)
    end
  end
  
  describe "with any credentials" do
    before(:each) do
      mock_WSDLDriverFactory = mock('WSDLDriverFactory')
      mock_RPCDriver = mock('Driver')
      mock_WSDLDriverFactory.should_receive(:create_rpc_driver).and_return(mock_RPCDriver)
      SOAP::WSDLDriverFactory.should_receive(:new).with('http://www.regonline.com/webservices/RetrieveSingleRegistration.asmx?WSDL').and_return(mock_WSDLDriverFactory)
      @roc_rsr = RegonlineConnector::Client::RetrieveSingleRegistration.new(100, 888, 'joeuser', 'password')
    end
    
    it "should not give read access to event_id" do
      lambda { @roc_rsr.event_id }.should raise_exception(NoMethodError)
    end
    
    it "should not give read access to registration_id" do
      lambda { @roc_rsr.registration_id }.should raise_exception(NoMethodError)
    end
    
    it "should not give read access to username" do
      lambda { @roc_rsr.username }.should raise_exception(NoMethodError)
    end
    
    it "should not give read access to password" do
      lambda { @roc_rsr.password }.should raise_exception(NoMethodError)
    end
    
    it "should not give write access to event_id" do
      lambda { @roc_rsr.event_id=200 }.should raise_exception(NoMethodError)
    end
    
    it "should not give write access to registration_id" do
      lambda { @roc_rsr.registration_id=200 }.should raise_exception(NoMethodError)
    end
        
    it "should not give write access to username" do
      lambda { @roc_rsr.username='joeuser' }.should raise_exception(NoMethodError)
    end
    
    it "should not give write access to password" do
      lambda { @roc_rsr.password='password' }.should raise_exception(NoMethodError)
    end
  end
  
  describe "with valid credentials" do
    before(:each) do
      @data = "valid_data"
      @xml = "<?xml version=\"1.0\" encoding=\"utf-8\"?><string xmlns=\"http://www.regonline.com/webservices/\">TESTING</string>"
      mock_WSDLDriverFactory = mock('SOAPWSDLDriverFactory')
      mock_RPCDriver = mock('SOAPRPCDriver')
      mock_MappingObject = mock('SOAPMappingObject')
      mock_MappingObject.stub(:retrieveSingleRegistrationResult).and_return(@data)
      mock_RPCDriver.stub(:RetrieveSingleRegistration).with(
                                    {"customerUserName" => 'joeuser',
                                     "customerPassword" => 'password',
                                     "eventID"          => 1000,
                                     "registrationID"   => 8888}
                                     ).and_return(mock_MappingObject)
      mock_WSDLDriverFactory.should_receive(:create_rpc_driver).and_return(mock_RPCDriver)
      SOAP::WSDLDriverFactory.should_receive(:new).with(
              'http://www.regonline.com/webservices/RetrieveSingleRegistration.asmx?WSDL'
              ).and_return(mock_WSDLDriverFactory)
      RegonlineConnector::Client.should_receive(:zip_to_xml).and_return(@xml)
      @roc_rsr = RegonlineConnector::Client::RetrieveSingleRegistration.new(1000, 8888, 'joeuser', 'password')
    end
    
    it "should return XML when RetrieveSingleRegistration is called" do
      @roc_rsr.RetrieveSingleRegistration.should == @xml
    end
  end
  
  describe "with invalid credentials" do
    before(:each) do
      mock_WSDLDriverFactory = mock('SOAPWSDLDriverFactory')
      mock_RPCDriver = mock('SOAPRPCDriver')
      mock_RPCDriver.stub(:RetrieveSingleRegistration).with(
                                    {"customerUserName" => 'joeuser',
                                     "customerPassword" => 'bad_password',
                                     "eventID"          => 1000,
                                     "registrationID"   => 8888}
                                     ).and_raise(SOAP::FaultError.new(
                                          SOAP::SOAPFault.new(SOAP::SOAPString.new('Server'),
                                                              SOAP::SOAPString.new('Authentication failure'))))
      mock_RPCDriver.stub(:RetrieveSingleRegistration).with(
                              {"customerUserName" => 'joeuser',
                               "customerPassword" => 'password',
                               "eventID"          => 9999,
                               "registrationID"   => 8888}
                               ).and_raise(SOAP::FaultError.new(
                                    SOAP::SOAPFault.new(SOAP::SOAPString.new('Server'),
                                                        SOAP::SOAPString.new('Object reference not set to an instance of an object.'))))
      mock_WSDLDriverFactory.should_receive(:create_rpc_driver).and_return(mock_RPCDriver)
      SOAP::WSDLDriverFactory.should_receive(:new).with(
              'http://www.regonline.com/webservices/RetrieveSingleRegistration.asmx?WSDL'
              ).and_return(mock_WSDLDriverFactory)
    end
    
    it "should raise a SOAP fault error with bad password" do 
      roc_rsr = RegonlineConnector::Client::RetrieveSingleRegistration.new(1000, 8888, 'joeuser', 'bad_password')
      lambda { roc_rsr.RetrieveSingleRegistration }.should raise_exception(SOAP::FaultError)
    end
    
    it "should raise a SOAP fault error with any bad event id" do
      roc_rsr = RegonlineConnector::Client::RetrieveSingleRegistration.new(9999, 8888, 'joeuser', 'password') 
      lambda { roc_rsr.RetrieveSingleRegistration }.should raise_exception(SOAP::FaultError)
    end
  end
end