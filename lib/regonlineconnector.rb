require 'regonlineconnector/client'
require 'regonlineconnector/parser'

class RegonlineConnector
  def initialize( account_id, username, password )
    @client  = RegonlineConnector::Client.new( account_id, username, password )
    @parser  = RegonlineConnector::Parser.new
  end
  
  def authenticate
    @authenticate = @client.authenticate
  end
  
  def get_events
    @parser.parse_events(@client.getEvents)
  end
  
  def get_event_registrations(event_id)
    @parser.parse_registrations(@client.getEventRegistrations(event_id))
  end
  
  def retrieve_all_registrations(event_id)
    @parser.parse_all_registrations(@client.retrieveAllRegistrations(event_id))
  end
end