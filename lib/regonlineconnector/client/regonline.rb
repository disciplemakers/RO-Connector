require 'soap/wsdlDriver'

class RegonlineConnector
  
  class Client
  
    class RegOnline

      def initialize(account_id, username, password, report_id, event_id, start_date, end_date, add_date)
        @account_id = account_id
        @username   = username
        @password   = password
        @report_id  = report_id
        @event_id   = event_id
        @start_date = start_date
        @end_date   = end_date
        @add_date   = add_date
        @wsdl       = 'http://www.regonline.com/activereports/RegOnline.asmx?WSDL'
        @report_getter = SOAP::WSDLDriverFactory.new(@wsdl).create_rpc_driver
      end

      def getReport
        response = @report_getter.getReport({"login"      => @username,
                                             "pass"       => @password,
                                             "customerID" => @account_id,
                                             "reportID"   => @report_id,
                                             "eventID"    => @event_id,
                                             "startDate"  => @start_date,
                                             "endDate"    => @end_date,
                                             "bAddDate"   => @add_date})
                                               
        registrations = RegonlineConnector::Client::zip_to_xml(
            response.getReportResult)
      end
      
    end
  
  end
  
end
