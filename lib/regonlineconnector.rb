require 'regonlineconnector/client'
require 'regonlineconnector/parser'
require 'regonlineconnector/error'

class RegonlineConnector
  def initialize(account_id, username, password)
    @client  = RegonlineConnector::Client.new(account_id, username, password)
    @parser  = RegonlineConnector::Parser.new
  end
  
  def authenticate
    @authenticate = @client.authenticate
  end
  
  def events
    @parser.parse_events(@client.getEvents.byAccountID)
  end
  
  def event(event_id)
    raise NotImplementedError    
  end
  
  def filtered_events(filter)
    raise NotImplementedError
  end
  
  # Returns hashed data from RegOnline's getEventRegistrations method.
  def simple_event_registrations(event_id)
    @parser.parse_registrations(@client.getEventRegistrations(event_id).RetrieveRegistrationInfo)
  end
  
  # Returns hashed data from RegOnline's retrieveAllRegistrations method.
  def event_registrations(event_id)
    @parser.parse_all_registrations(@client.retrieveAllRegistrations(event_id).RetrieveAllRegistrations)
  end
end