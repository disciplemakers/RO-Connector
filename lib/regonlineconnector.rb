require 'regonlineconnector/client'
require 'regonlineconnector/parser'
require 'regonlineconnector/error'

# Class providing a gateway to other classes that connect to RegOnline.
class RegonlineConnector
  def initialize(account_id, username, password)
    @client  = RegonlineConnector::Client.new(account_id, username, password)
    @parser  = RegonlineConnector::Parser.new
  end
  
  # Returns boolean indicating whether valid login credentials have
  # been supplied.
  def authenticate
    @authenticate = @client.authenticate
  end
  
  # Returns hashed data from RegOnline's getEvents.byAccountID method.
  def events
    @parser.parse_events(@client.getEvents.byAccountID)
  end
  
  # Returns hashed data from RegOnline's getEvents.byAccountIDEventID method.
  def event(event_id)
    @parser.parse_events(@client.getEvents.byAccountIDEventID(event_id))
  end
  
  # Returns hashed data from RegOnline's getEvents.byAccountIDWithFilters
  # method. Not yet implemented.
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