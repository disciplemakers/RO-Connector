require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "RegistrationUpdateService" do
  describe "without credentials" do
    it "shouldn't instantiate" do
      lambda { roc_rusonline = RegonlineConnector::Client::RegistrationUpdateService.new }.should raise_exception(ArgumentError)
    end
  end
  
  describe "with any credentials" do
    before(:each) do    
      @roc_rus = RegonlineConnector::Client::RegistrationUpdateService.new('joeuser',
                                                                          'password')
    end
    
    it "should not give read access to username" do
      lambda { @roc_rus.username }.should raise_exception(NoMethodError)
    end
    
    it "should not give read access to password" do
      lambda { @roc_rus.password }.should raise_exception(NoMethodError)
    end

    it "should not give write access to username" do
      lambda { @roc_rus.username='joeuser' }.should raise_exception(NoMethodError)
    end
    
    it "should not give write access to password" do
      lambda { @roc_rus.password='password' }.should raise_exception(NoMethodError)
    end
    
    it "should return request xml string when given an event id and update data" do
      @request_xml = <<"EOF";
<?xml version="1.0" encoding="utf-8" ?>
<env:Envelope xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">
  <env:Header>
      <updateRegistrationsRequestHeader env:mustUnderstand="0"
          xmlns="http://www.regonline.com/webservices/2007/08/RegistrationUpdateService">
        <login>joeuser</login>
        <password>password</password></updateRegistrationsRequestHeader>
  </env:Header>
  <env:Body>
    <UpdateRegistrationsRequest xmlns="http://www.regonline.com/webservices/2007/08/RegistrationUpdateService">
      <eventID xmlns="http://www.regonline.com/webservices/2007/08/RegistrationUpdateServiceTypes">123456</eventID>
      <registrations xmlns="http://www.regonline.com/webservices/2007/08/RegistrationUpdateServiceTypes">
        <registration>
          <registrationId>12345678</registrationId>
           <customFields>
            <customField>
              <fieldName>Field Name</fieldName>
              <value>Field Value</value>
              <quantity>1</quantity>
            </customField>
          </customFields>
        </registration>
      </registrations>
    </UpdateRegistrationsRequest>
  </env:Body>
</env:Envelope>
EOF
      @event_id = 123456
      @update_data_hash = { 12345678 => {
                              "custom_fields" => {"Field Name" => "Field Value"}
                          } } 
      @roc_rus.generate_request_xml(@event_id, @update_data_hash)
    end
  end
  
  describe "with valid credentials" do
    before(:each) do
      @request_xml = <<"EOF";
<?xml version="1.0" encoding="utf-8" ?>
<env:Envelope xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">
  <env:Header>
      <updateRegistrationsRequestHeader env:mustUnderstand="0"
          xmlns="http://www.regonline.com/webservices/2007/08/RegistrationUpdateService">
        <login>joeuser</login>
        <password>password</password></updateRegistrationsRequestHeader>
  </env:Header>
  <env:Body>
    <UpdateRegistrationsRequest xmlns="http://www.regonline.com/webservices/2007/08/RegistrationUpdateService">
      <eventID xmlns="http://www.regonline.com/webservices/2007/08/RegistrationUpdateServiceTypes">123456</eventID>
      <registrations xmlns="http://www.regonline.com/webservices/2007/08/RegistrationUpdateServiceTypes">
        <registration>
          <registrationId>12345678</registrationId>
          <customFields>
            <customField>
              <fieldName>Field Name</fieldName>
              <value>Field Value</value>
              <quantity>1</quantity>
            </customField>
          </customFields>
        </registration>
      </registrations>
    </UpdateRegistrationsRequest>
  </env:Body>
</env:Envelope>
EOF
      @resp_data = "<?xml version=\"1.0\" encoding=\"utf-8\"?>" +
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
      @mock_http_stream_handler = mock('HTTPStreamHandler')
      SOAP::HTTPStreamHandler.stub(:new).with(any_args()).and_return(@mock_http_stream_handler)      
      @roc_rus = RegonlineConnector::Client::RegistrationUpdateService.new('joeuser',
                                                                          'password')
    end
    
    it "should return XML when UpdateRegistrationService is called" do
      request = SOAP::StreamHandler::ConnectionData.new(@request_xml)
      SOAP::StreamHandler::ConnectionData.stub(:new).with(@request_xml).and_return(request)
      @mock_http_stream_handler.stub(:send).with(
                      'http://www.regonline.com/webservices/RegistrationUpdateService.asmx',
                      request,
                      "http://www.regonline.com/webservices/2007/08/RegistrationUpdateService/UpdateRegistrations"
                     ).and_return(@resp_data)
      
      @roc_rus.UpdateRegistrations(@request_xml).should == @resp_data
    end
    
    it "should raise a SOAP fault error with registrant that doesn't belong to event" do
      request = SOAP::StreamHandler::ConnectionData.new(@request_xml)
      SOAP::StreamHandler::ConnectionData.stub(:new).with(@request_xml).and_return(request)
      @mock_http_stream_handler.stub(:send).with(
                      'http://www.regonline.com/webservices/RegistrationUpdateService.asmx',
                      request,
                      "http://www.regonline.com/webservices/2007/08/RegistrationUpdateService/UpdateRegistrations"
           ).and_raise(SOAP::FaultError.new(
                                SOAP::SOAPFault.new(SOAP::SOAPString.new('Server'),
                                                    SOAP::SOAPString.new('Registration Id 12345678 is not valid for event Id 123456'))))
                                                    
      lambda { @roc_rus.UpdateRegistrations(@request_xml) }.should raise_exception(SOAP::FaultError)
    end
    it "should raise a SOAP fault error with incorrect custom field name" do
      request = SOAP::StreamHandler::ConnectionData.new(@request_xml)
      SOAP::StreamHandler::ConnectionData.stub(:new).with(@request_xml).and_return(request)
      @mock_http_stream_handler.stub(:send).with(
                      'http://www.regonline.com/webservices/RegistrationUpdateService.asmx',
                      request,
                      "http://www.regonline.com/webservices/2007/08/RegistrationUpdateService/UpdateRegistrations"
           ).and_raise(SOAP::FaultError.new(
                                SOAP::SOAPFault.new(SOAP::SOAPString.new('Server'),
                                                    SOAP::SOAPString.new('Object reference not set to an instance of an object.'))))
                                                    
      lambda { @roc_rus.UpdateRegistrations(@request_xml) }.should raise_exception(SOAP::FaultError)
    end
  end
  
  describe "with invalid credentials" do
    before(:each) do
      @mock_http_stream_handler = mock('HTTPStreamHandler')
      SOAP::HTTPStreamHandler.stub(:new).with(any_args()).and_return(@mock_http_stream_handler)      
      @roc_rus = RegonlineConnector::Client::RegistrationUpdateService.new('joeuser',
                                                                          'password')
    end
    
    it "should raise a SOAP fault error with bad username" do
      request_xml = <<"EOF";
<?xml version="1.0" encoding="utf-8" ?>
<env:Envelope xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">
  <env:Header>
      <updateRegistrationsRequestHeader env:mustUnderstand="0"
          xmlns="http://www.regonline.com/webservices/2007/08/RegistrationUpdateService">
        <login>bad_username</login>
        <password>password</password></updateRegistrationsRequestHeader>
  </env:Header>
  <env:Body>
    <UpdateRegistrationsRequest xmlns="http://www.regonline.com/webservices/2007/08/RegistrationUpdateService">
      <eventID xmlns="http://www.regonline.com/webservices/2007/08/RegistrationUpdateServiceTypes">123456</eventID>
      <registrations xmlns="http://www.regonline.com/webservices/2007/08/RegistrationUpdateServiceTypes">
        <registration>
          <registrationId>12345678</registrationId>
          <customFields>
            <customField>
              <fieldName>Field Name</fieldName>
              <value>Field Value</value>
              <quantity>1</quantity>
            </customField>
          </customFields>
        </registration>
      </registrations>
    </UpdateRegistrationsRequest>
  </env:Body>
</env:Envelope>
EOF
      request = SOAP::StreamHandler::ConnectionData.new(request_xml)
      SOAP::StreamHandler::ConnectionData.stub(:new).with(request_xml).and_return(request)
      @mock_http_stream_handler.stub(:send).with(
                      'http://www.regonline.com/webservices/RegistrationUpdateService.asmx',
                      request,
                      "http://www.regonline.com/webservices/2007/08/RegistrationUpdateService/UpdateRegistrations"
           ).and_raise(SOAP::FaultError.new(
                                SOAP::SOAPFault.new(SOAP::SOAPString.new('Server'),
                                                    SOAP::SOAPString.new('Authentication failure'))))
                                                    
      lambda { @roc_rus.UpdateRegistrations(request_xml) }.should raise_exception(SOAP::FaultError)
    end
    
    it "should raise a SOAP fault error with bad password" do
      request_xml = <<"EOF";
<?xml version="1.0" encoding="utf-8" ?>
<env:Envelope xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">
  <env:Header>
      <updateRegistrationsRequestHeader env:mustUnderstand="0"
          xmlns="http://www.regonline.com/webservices/2007/08/RegistrationUpdateService">
        <login>joeuser</login>
        <password>bad_password</password></updateRegistrationsRequestHeader>
  </env:Header>
  <env:Body>
    <UpdateRegistrationsRequest xmlns="http://www.regonline.com/webservices/2007/08/RegistrationUpdateService">
      <eventID xmlns="http://www.regonline.com/webservices/2007/08/RegistrationUpdateServiceTypes">123456</eventID>
      <registrations xmlns="http://www.regonline.com/webservices/2007/08/RegistrationUpdateServiceTypes">
        <registration>
          <registrationId>12345678</registrationId>
          <customFields>
            <customField>
              <fieldName>Field Name</fieldName>
              <value>Field Value</value>
              <quantity>1</quantity>
            </customField>
          </customFields>
        </registration>
      </registrations>
    </UpdateRegistrationsRequest>
  </env:Body>
</env:Envelope>
EOF
      request = SOAP::StreamHandler::ConnectionData.new(request_xml)
      SOAP::StreamHandler::ConnectionData.stub(:new).with(request_xml).and_return(request)
      @mock_http_stream_handler.stub(:send).with(
                      'http://www.regonline.com/webservices/RegistrationUpdateService.asmx',
                      request,
                      "http://www.regonline.com/webservices/2007/08/RegistrationUpdateService/UpdateRegistrations"
           ).and_raise(SOAP::FaultError.new(
                                SOAP::SOAPFault.new(SOAP::SOAPString.new('Server'),
                                                    SOAP::SOAPString.new('Authentication failure'))))
                                                    
      lambda { @roc_rus.UpdateRegistrations(request_xml) }.should raise_exception(SOAP::FaultError)
    end

    it "should raise a SOAP fault error with bad event id" do
      request_xml = <<"EOF";
<?xml version="1.0" encoding="utf-8" ?>
<env:Envelope xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">
  <env:Header>
      <updateRegistrationsRequestHeader env:mustUnderstand="0"
          xmlns="http://www.regonline.com/webservices/2007/08/RegistrationUpdateService">
        <login>joeuser</login>
        <password>password</password></updateRegistrationsRequestHeader>
  </env:Header>
  <env:Body>
    <UpdateRegistrationsRequest xmlns="http://www.regonline.com/webservices/2007/08/RegistrationUpdateService">
      <eventID xmlns="http://www.regonline.com/webservices/2007/08/RegistrationUpdateServiceTypes">123456</eventID>
      <registrations xmlns="http://www.regonline.com/webservices/2007/08/RegistrationUpdateServiceTypes">
        <registration>
          <registrationId>99999999</registrationId>
          <customFields>
            <customField>
              <fieldName>Field Name</fieldName>
              <value>Field Value</value>
              <quantity>1</quantity>
            </customField>
          </customFields>
        </registration>
      </registrations>
    </UpdateRegistrationsRequest>
  </env:Body>
</env:Envelope>
EOF
      request = SOAP::StreamHandler::ConnectionData.new(request_xml)
      SOAP::StreamHandler::ConnectionData.stub(:new).with(request_xml).and_return(request)
      @mock_http_stream_handler.stub(:send).with(
                      'http://www.regonline.com/webservices/RegistrationUpdateService.asmx',
                      request,
                      "http://www.regonline.com/webservices/2007/08/RegistrationUpdateService/UpdateRegistrations"
           ).and_raise(SOAP::FaultError.new(
                                SOAP::SOAPFault.new(SOAP::SOAPString.new('Server'),
                                                    SOAP::SOAPString.new('Authentication failure'))))
                                                    
      lambda { @roc_rus.UpdateRegistrations(request_xml) }.should raise_exception(SOAP::FaultError)
    end
  end
end