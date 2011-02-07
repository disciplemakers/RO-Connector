require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "RegOnline" do
  describe "without credentials" do
    it "shouldn't instantiate" do
      lambda { roc_regonline = RegonlineConnector::Client::RegOnline.new }.should raise_exception(ArgumentError)
    end
  end
  
  describe "with any credentials" do
    before(:each) do
      mock_WSDLDriverFactory = mock('WSDLDriverFactory')
      mock_RPCDriver = mock('Driver')
      mock_WSDLDriverFactory.should_receive(:create_rpc_driver).and_return(mock_RPCDriver)
      SOAP::WSDLDriverFactory.should_receive(:new).with('http://www.regonline.com/activereports/RegOnline.asmx?WSDL').and_return(mock_WSDLDriverFactory)
      @roc_ro = RegonlineConnector::Client::RegOnline.new(100, 'joeuser', 'password', 10000, 1000, '1/1/2010',
                                                          '12/31/2010', 'true')
    end
    
    it "should not give read access to account_id" do
      lambda { @roc_ro.account_id }.should raise_exception(NoMethodError)
    end
    
    it "should not give read access to username" do
      lambda { @roc_ro.username }.should raise_exception(NoMethodError)
    end
    
    it "should not give read access to password" do
      lambda { @roc_ro.password }.should raise_exception(NoMethodError)
    end

    it "should not give read access to report_id" do
      lambda { @roc_ro.report_id }.should raise_exception(NoMethodError)
    end
    
    it "should not give read access to event_id" do
      lambda { @roc_ro.event_id }.should raise_exception(NoMethodError)
    end
    
    it "should not give read access to start_date" do
      lambda { @roc_ro.start_date }.should raise_exception(NoMethodError)
    end
    it "should not give read access to end_date" do
      lambda { @roc_ro.end_date }.should raise_exception(NoMethodError)
    end
    
    it "should not give read access to add_date" do
      lambda { @roc_ro.add_date }.should raise_exception(NoMethodError)
    end
    
    it "should not give write access to account_id" do
      lambda { @roc_ro.account_id=200 }.should raise_exception(NoMethodError)
    end
    
    it "should not give write access to username" do
      lambda { @roc_ro.username='joeuser' }.should raise_exception(NoMethodError)
    end
    
    it "should not give write access to password" do
      lambda { @roc_ro.password='password' }.should raise_exception(NoMethodError)
    end
    
    it "should not give write access to report_id" do
      lambda { @roc_ro.report_id=200 }.should raise_exception(NoMethodError)
    end

    it "should not give write access to event_id" do
      lambda { @roc_ro.event_id=200 }.should raise_exception(NoMethodError)
    end
    
    it "should not give write access to start_date" do
      lambda { @roc_ro.start_date="1/1/2000" }.should raise_exception(NoMethodError)
    end
    
    it "should not give write access to end_date" do
      lambda { @roc_ro.end_date="1/1/2000" }.should raise_exception(NoMethodError)
    end
    
    it "should not give write access to add_date" do
      lambda { @roc_ro.add_date="false" }.should raise_exception(NoMethodError)
    end
  end
  
  describe "with valid credentials" do
    before(:each) do
      @data = "valid_data"
      @xml = "<?xml version=\"1.0\" encoding=\"utf-8\"?><string xmlns=\"http://www.regonline.com/webservices/\">TESTING</string>"
      mock_WSDLDriverFactory = mock('SOAPWSDLDriverFactory')
      mock_RPCDriver = mock('SOAPRPCDriver')
      mock_MappingObject = mock('SOAPMappingObject')
      mock_MappingObject.stub(:getReportResult).and_return(@data)
      mock_RPCDriver.stub(:getReport).with(
                                    {"login"      => 'joeuser',
                                     "pass"       => 'password',
                                     "eventID"    => 1000,
                                     "reportID"   => 10000,
                                     "customerID" => 100,
                                     "startDate"  => '1/1/2010',
                                     "endDate"    => '12/31/2010',
                                     "bAddDate"   => 'true'}
                                     ).and_return(mock_MappingObject)
      mock_WSDLDriverFactory.should_receive(:create_rpc_driver).and_return(mock_RPCDriver)
      SOAP::WSDLDriverFactory.should_receive(:new).with(
              'http://www.regonline.com/activereports/RegOnline.asmx?WSDL'
              ).and_return(mock_WSDLDriverFactory)
      RegonlineConnector::Client.should_receive(:zip_to_xml).and_return(@xml)
      @roc_ro = RegonlineConnector::Client::RegOnline.new(100, 'joeuser', 'password', 10000, 1000, '1/1/2010',
                                                          '12/31/2010', 'true')
    end
    
    it "should return XML when RetrieveAllRegistrations is called" do
      @roc_ro.getReport.should == @xml
    end
  end
  
  describe "with invalid credentials" do
    before(:each) do
      @xml = "Error 4458: unable to process request."
      mock_MappingObject = mock('SOAPMappingObject')
      mock_MappingObject.stub(:getReportResult).and_return(@xml)
      
      @empty_zip = "UEsDBC0AAAAIAD1hRz6ioznn//////////8EABQAZGF0YQEAEAAeAAAAA" +
                   "AAAACUAAAAAAAAADcWxDQAQEADAG8UGFhBD2EAholF4+4drrmiGaQnX0e" +
                   "1/SLLqAVBLAQItAC0AAAAIAD1hRz6ioznn//////////8EABQAAAAAAAA" +
                   "AAAAAAAAAAABkYXRhAQAQAB4AAAAAAAAAJQAAAAAAAABQSwUGAAAAAAEA" +
                   "AQBGAAAAWwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" +
                   "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=="
      @empty_xml = "<?xml version=\"1.0\" encoding=\"utf-8\"?><string " +
                   "xmlns=\"http://www.regonline.com/webservices/\">" +
                   "<Registrants /></string>"
      mock_MappingObjectEmpty = mock('SOAPMappingObject')
      mock_MappingObjectEmpty.stub(:getReportResult).and_return(@empty_zip)
      
      mock_WSDLDriverFactory = mock('SOAPWSDLDriverFactory')
      mock_RPCDriver = mock('SOAPRPCDriver')
      mock_RPCDriver.stub(:getReport).with(
                                    {"login"      => 'joeuser',
                                     "pass"       => 'password',
                                     "eventID"    => 1000,
                                     "reportID"   => 10000,
                                     "customerID" => 100,
                                     "startDate"  => '1/1/2010',
                                     "endDate"    => '12/31/2010',
                                     "bAddDate"   => 'true'}
                                     ).and_return(mock_MappingObject)
      mock_RPCDriver.stub(:getReport).with(
                                    {"login"      => 'joeuser',
                                     "pass"       => 'bad_password',
                                     "eventID"    => 1000,
                                     "reportID"   => 10000,
                                     "customerID" => 100,
                                     "startDate"  => '1/1/2010',
                                     "endDate"    => '12/31/2010',
                                     "bAddDate"   => 'true'}
                                     ).and_return(mock_MappingObjectEmpty)
      mock_WSDLDriverFactory.should_receive(:create_rpc_driver).and_return(mock_RPCDriver)
      SOAP::WSDLDriverFactory.should_receive(:new).with(
              'http://www.regonline.com/activereports/RegOnline.asmx?WSDL'
              ).and_return(mock_WSDLDriverFactory)
    end
    
    pending "should still return xml unable to process request message with bad password" do 
      roc_ro = RegonlineConnector::Client::RegOnline.new(100, 'joeuser', 'bad_password', 10000, 1000, '1/1/2010',
                                                          '12/31/2010', 'true')
      lambda { roc_ro.getReport }.should == @xml
    end
    
    pending "should raise a SOAP fault error with bad search criteria" do
      roc_ro = RegonlineConnector::Client::RegOnline.new(100, 'joeuser', 'password', 10000, 1000, '1/1/2010',
                                                          '12/31/2010', 'true') 
      lambda { roc_ro.getReport }.should raise_exception(SOAP::FaultError)
    end
  end
  
end