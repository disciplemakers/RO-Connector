require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "RegonlineConnector" do
  
  describe "without credentials" do
    it "shouldn't instantiate" do
      lambda { roc = RegonlineConnector.new }.should raise_exception(ArgumentError)
    end
  end
  
  describe "with any credentials" do
    before(:each) do
      @roc = RegonlineConnector.new(100, 'joeuser', 'password')
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
    
  describe "with valid credentials" do
    before(:each) do
      mock_getEvents = mock('getEvents')
      mock_getEvents.should_receive(:Authenticate).and_return(true)
      
      # Instantiate our mock GetEvents object instead of a real one.
      RegonlineConnector::Client::GetEvents.should_receive(:new).with(100, 'joeuser', 'password').and_return(mock_getEvents)
      @roc = RegonlineConnector.new(100, 'joeuser', 'password')
    end
    
    it "should successfully authenticate" do
      @roc.authenticate.should == true
    end
  end
    
  describe "with invalid credentials" do
    it "should not successfully authenticate" do
      mock_client = mock('roc_client')
      mock_client.should_receive(:authenticate).and_return(false)
      RegonlineConnector::Client.should_receive(:new).with(100, 'joeuser', 'bad_password').and_return(mock_client)
      roc = RegonlineConnector.new(100, 'joeuser', 'bad_password')
      roc.authenticate.should == false
    end
    
    it "should raise authentication error when getting all events" do
      # Our implementation couples the RegonlineConnector class and the Client
      # class in that the RegonlineConnector knows about the internals of
      # the service objects that the Client handles.  Therefore our testing
      # of the RegonlineConnector object needs to go a couple levels deep in
      # what it tests.
      
      # Create a mock GetEvents object (this is the object that wraps
      # RegOnline's getEvents.asmx service).
      mock_getEvents = mock('getEvents')
      mock_getEvents.should_receive(:ByAccountID).and_return("The credentials you supplied are not valid.")
      
      # Instantiate our mock GetEvents object instead of a real one.
      RegonlineConnector::Client::GetEvents.should_receive(:new).with(100, 'joeuser', 'bad_password').and_return(mock_getEvents)
      
      roc = RegonlineConnector.new(100, 'joeuser', 'bad_password')
      lambda { roc.events }.should raise_exception(RegonlineConnector::AuthenticationError)
    end
    
    it "should raise authentication error when getting a single event" do
      # Create a mock GetEvents object (this is the object that wraps
      # RegOnline's getEvents.asmx service).
      mock_getEvents = mock('getEvents')
      mock_getEvents.should_receive(:ByAccountIDEventID).with(1000).and_return("The credentials you supplied are not valid.")
      
      # Instantiate our mock GetEvents object instead of a real one.
      RegonlineConnector::Client::GetEvents.should_receive(:new).with(100, 'joeuser', 'bad_password').and_return(mock_getEvents)
      
      roc = RegonlineConnector.new(100, 'joeuser', 'bad_password')
      lambda { roc.event(1000) }.should raise_exception(RegonlineConnector::AuthenticationError) 
    end
   
    
    it "should raise not implemented error when getting events using filter(s)" do
      roc = RegonlineConnector.new(100, 'joeuser', 'bad_password')
      lambda { roc.filtered_events(1000) }.should raise_exception(NotImplementedError) 
    end
   
    it "should raise authentication error when retrieving event fields data" do
      mock_getEventFields = mock('getEventFields')
      mock_getEventFields.should_receive(:RetrieveEventFields2).and_raise(SOAP::FaultError.new(
                                       SOAP::SOAPFault.new(SOAP::SOAPString.new('Server'),
                                                           SOAP::SOAPString.new('Authentication failure'))))
      
      # Instantiate our mock getEventFields object instead of a real one.
      RegonlineConnector::Client::GetEventFields.should_receive(:new).with(1000, 'joeuser', 'bad_password', 'false').and_return(mock_getEventFields)
      
      roc = RegonlineConnector.new(100, 'joeuser', 'bad_password')
      lambda { roc.event_fields(1000) }.should raise_exception(RegonlineConnector::AuthenticationError)
    end
    
    it "should raise authentication error when retrieving simple event registrations data" do
      mock_getEventRegistrations = mock('getEventRegistrations')
      mock_getEventRegistrations.should_receive(:RetrieveRegistrationInfo).and_raise(SOAP::FaultError.new(
                                       SOAP::SOAPFault.new(SOAP::SOAPString.new('Server'),
                                                           SOAP::SOAPString.new('Authentication failure'))))
      
      # Instantiate our mock getEventRegistrations object instead of a real one.
      RegonlineConnector::Client::GetEventRegistrations.should_receive(:new).with(1000, 'joeuser', 'bad_password').and_return(mock_getEventRegistrations)
      
      roc = RegonlineConnector.new(100, 'joeuser', 'bad_password')
      lambda { roc.simple_event_registrations(1000) }.should raise_exception(RegonlineConnector::AuthenticationError)
    end
       
    it "should raise authentication error when retrieving fuller event registrations data" do
      mock_RetrieveAllRegistrations = mock('RetrieveAllRegistrations')
      mock_RetrieveAllRegistrations.should_receive(:RetrieveAllRegistrations).and_raise(SOAP::FaultError.new(
                                          SOAP::SOAPFault.new(SOAP::SOAPString.new('Server'),
                                                              SOAP::SOAPString.new('Authentication failure'))))
      
      # Instantiate our mock RetrieveAllRegistrations object instead of a real one.
      RegonlineConnector::Client::RetrieveAllRegistrations.should_receive(:new).with(1000, 'joeuser', 'bad_password').and_return(mock_RetrieveAllRegistrations)
      
      roc = RegonlineConnector.new(100, 'joeuser', 'bad_password')
      lambda { roc.event_registrations(1000) }.should raise_exception(RegonlineConnector::AuthenticationError)
    end

    it "should raise authentication error when retrieving fuller single registration data" do
      mock_RetrieveSingleRegistration = mock('RetrieveSingleRegistration')
      mock_RetrieveSingleRegistration.should_receive(:RetrieveSingleRegistration).and_raise(SOAP::FaultError.new(
                                          SOAP::SOAPFault.new(SOAP::SOAPString.new('Server'),
                                                              SOAP::SOAPString.new('Authentication failure'))))
      
      # Instantiate our mock RetrieveSingleRegistration object instead of a real one.
      RegonlineConnector::Client::RetrieveSingleRegistration.should_receive(:new).with(1000, 10000, 'joeuser', 'bad_password').and_return(mock_RetrieveSingleRegistration)
      
      roc = RegonlineConnector.new(100, 'joeuser', 'bad_password')
      lambda { roc.registration(1000,10000) }.should raise_exception(RegonlineConnector::AuthenticationError)
    end
    
  end
  
  describe "with valid credentials but invalid selection criteria" do   
    it "should raise regonline server error when retrieving event fields data" do
      mock_getEventFields = mock('getEventFields')
      mock_getEventFields.should_receive(:RetrieveEventFields2).and_raise(SOAP::FaultError.new(
                                       SOAP::SOAPFault.new(SOAP::SOAPString.new('Server'),
                                                           SOAP::SOAPString.new('Object reference not set to an instance of an object.'))))
      
      # Instantiate our mock getEventFields object instead of a real one.
      RegonlineConnector::Client::GetEventFields.should_receive(:new).with(1000, 'joeuser', 'bad_password', 'false').and_return(mock_getEventFields)
      
      roc = RegonlineConnector.new(100, 'joeuser', 'bad_password')
      lambda { roc.event_fields(1000) }.should raise_exception(RegonlineConnector::RegonlineServerError)
    end
    
    it "should raise regonline server error when retrieving simple event registrations data" do
      mock_getEventRegistrations = mock('getEventRegistrations')
      mock_getEventRegistrations.should_receive(:RetrieveRegistrationInfo).and_raise(SOAP::FaultError.new(
                                       SOAP::SOAPFault.new(SOAP::SOAPString.new('Server'),
                                                           SOAP::SOAPString.new('Object reference not set to an instance of an object.'))))

      # Instantiate our mock getEventRegistrations object instead of a real one.
      RegonlineConnector::Client::GetEventRegistrations.should_receive(:new).with(1000, 'joeuser', 'password').and_return(mock_getEventRegistrations)
      
      roc = RegonlineConnector.new(100, 'joeuser', 'password')
      lambda { roc.simple_event_registrations(1000) }.should raise_exception(RegonlineConnector::RegonlineServerError)
    end
       
    it "should raise regonline server error when retrieving fuller event registrations data" do
      mock_RetrieveAllRegistrations = mock('RetrieveAllRegistrations')
      mock_RetrieveAllRegistrations.should_receive(:RetrieveAllRegistrations).and_raise(SOAP::FaultError.new(
                                          SOAP::SOAPFault.new(SOAP::SOAPString.new('Server'),
                                                              SOAP::SOAPString.new('Object reference not set to an instance of an object.'))))
      
      # Instantiate our mock RetrieveAllRegistrations object instead of a real one.
      RegonlineConnector::Client::RetrieveAllRegistrations.should_receive(:new).with(1000, 'joeuser', 'password').and_return(mock_RetrieveAllRegistrations)
      
      roc = RegonlineConnector.new(100, 'joeuser', 'password')
      lambda { roc.event_registrations(1000) }.should raise_exception(RegonlineConnector::RegonlineServerError)
    end

    it "should raise regonline server error when retrieving fuller single registration data" do
      mock_RetrieveSingleRegistration = mock('RetrieveSingleRegistration')
      mock_RetrieveSingleRegistration.should_receive(:RetrieveSingleRegistration).and_raise(SOAP::FaultError.new(
                                          SOAP::SOAPFault.new(SOAP::SOAPString.new('Server'),
                                                              SOAP::SOAPString.new('Object reference not set to an instance of an object.'))))
      
      # Instantiate our mock RetrieveSingleRegistration object instead of a real one.
      RegonlineConnector::Client::RetrieveSingleRegistration.should_receive(:new).with(1000, 10000, 'joeuser', 'password').and_return(mock_RetrieveSingleRegistration)
      
      roc = RegonlineConnector.new(100, 'joeuser', 'password')
      lambda { roc.registration(1000,10000) }.should raise_exception(RegonlineConnector::RegonlineServerError)
    end
  end
end
