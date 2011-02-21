require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "RegistrationUpdateService" do
  describe "without credentials" do
    it "shouldn't instantiate" do
      lambda { roc_rusonline = RegonlineConnector::Client::RegistrationUpdateService.new }.should raise_exception(ArgumentError)
    end
  end
  
  describe "with any credentials" do
    before(:each) do
      resp_data = "<?xml version=\"1.0\" encoding=\"utf-8\"?>" +
                  "<soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\" " +
                  "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" " +
                  "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\">" +
                  "<soap:Body>" +
                  "<UpdateRegistrationsResponse " +
                  "xmlns=\"http://www.regonline.com/webservices/2007/08/RegistrationUpdateService\">" +
                  "<updateRegistrationsResult " +
                  "xmlns=\"http://www.regonline.com/webservices/2007/08/RegistrationUpdateServiceTypes\">" +
                  "12345678</updateRegistrationsResult></UpdateRegistrationsResponse></soap:Body>" +
                  "</soap:Envelope>"
      mock_http_stream_handler = mock('HTTPStreamHandler')
      mock_http_stream_handler.stub(:send).with(
                      'http://www.regonline.com/webservices/RegistrationUpdateService.asmx',
                      "request",
                      "http://www.regonline.com/webservices/2007/08/RegistrationUpdateService/UpdateRegistrations"
                     ).and_return(resp_data)
      SOAP::HTTPStreamHandler.stub(:new).with(any_args()).and_return(mock_http_stream_handler)      
      @roc_rus = RegonlineConnector::Client::RegistrationUpdateService.new('joeuser',
                                                                          'password')
    end
    
    it "should not give read access to username" do
      lambda { @roc_ro.username }.should raise_exception(NoMethodError)
    end
    
    it "should not give read access to password" do
      lambda { @roc_ro.password }.should raise_exception(NoMethodError)
    end

    it "should not give write access to username" do
      lambda { @roc_ro.username='joeuser' }.should raise_exception(NoMethodError)
    end
    
    it "should not give write access to password" do
      lambda { @roc_ro.password='password' }.should raise_exception(NoMethodError)
    end
  end
end