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
  
  def getEventRegistrations(event_id)
    @get_event_registrations = @client.getEventRegistrations( event_id )
  end
  
  def parseRegistrations(response)
    @parser.parse_registrations(response)
  end
  
  def retrieveAllRegistrations(event_id)
    @retrieve_all_registrations = @client.retrieveAllRegistrations( event_id )
  end

  def parseAllRegistrations(response)
    @parser.parse_all_registrations(response)
  end
  
end

