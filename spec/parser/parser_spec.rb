require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Parser" do
  describe "with data" do
    before(:each) do
      @parser = RegonlineConnector::Parser.new
      @ev_xml = "<NewDataSet>\n  <Table>\n    <ID>999999</ID>\n    " +
                "<Status>Testing</Status>\n    <Type>Event</Type>\n    " +
                "<ClientID />\n    <Title>Test Conference</Title>\n    " +
                "<LocationName>Conference Center</LocationName>\n    <Room />\n" +
                "</Table>\n</NewDataSet>"
      @ev_hash = {999999 => {"ID"           => 999999,
                             "Status"       => "Testing",
                             "Type"         => "Event",
                             "ClientID"     => nil,
                             "Title"        => "Test Conference",
                             "LocationName" => "Conference Center",
                             "Room"         => nil}}
      @sreg_xml = "<registrations>" +
                 "<registration id=\"12345678\" firstName=\"John\" lastName=\"Doe\" />" +
                 "</registrations>"
      @sreg_hash = {12345678 => {"id"        => 12345678,
                                "firstName" => "John",
                                "lastName"  => "Doe"}}
      @reg_xml = "<string><Registration><membershipID />" +
                 "<registrationID>12345678</registrationID>" +
                 "<prefix /><firstName>John</firstName><middleName>Q</middleName>" +
                 "<lastName>Doe</lastName><suffix />" +
                 "</Registration></string>"
      @reg_hash = {12345678 => {"registrationID" => 12345678,
                                "lastName"       => "Doe",
                                "prefix"         => nil,
                                "middleName"     => "Q",
                                "firstName"      => "John",
                                "suffix"         => nil,
                                "membershipID"   => nil}}
      @updated_registrations_xml = "<?xml version=\"1.0\" encoding=\"utf-8\"?>" +
                                   "<soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\" " +
                                   "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" " +
                                   "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\"><soap:Body>" +
                                   "<UpdateRegistrationsResponse " +
                                   "xmlns=\"http://www.regonline.com/webservices/2007/08/RegistrationUpdateService\">" +
                                   "<updateRegistrationsResult " +
                                   "xmlns=\"http://www.regonline.com/webservices/2007/08/RegistrationUpdateServiceTypes\">" +
                                   "12345678,87654321,24681012,12108642" +
                                   "</updateRegistrationsResult></UpdateRegistrationsResponse>" +
                                   "</soap:Body></soap:Envelope>"
      @updated_registrations_array = [ 12345678, 87654321, 24681012, 12108642]
    end
    
    it "events parser should return hashed data" do
      @parser.parse_events(@ev_xml).should == @ev_hash
    end

    it "simple registration parser should return hashed data" do
      @parser.parse_simple_registrations(@sreg_xml).should == @sreg_hash
    end
    
    it "registration parser should return hashed data" do
      @parser.parse_registrations(@reg_xml).should == @reg_hash
    end
    
    it "updated registrations parser should return array of updated registration ids" do
      @parser.parse_updated_registrations(@updated_registrations_xml).should == @updated_registrations_array
    end   
  end
  
  describe "with empty data set" do
    before(:each) do
      @parser = RegonlineConnector::Parser.new
      @ev_xml = "<NewDataSet>\n  <Table>\n    </Table>\n</NewDataSet>"
      @ev_hash = {}
      @sreg_xml = "<registrations />"
      @sreg_hash = {}
      @reg_xml = "<string></string>"
      @reg_hash = {}
      @rep_xml_one_element = "<Registrants />"
      @rep_xml_many_elements = "<Registrants>\n  <Table1 />\n  " +
                                     "<Table1 />\n  <Table1 />\n  " +
                                     "<Table1 />\n  <Table1 />\n  " +
                                     "<Table1 />\n  <Table1 />\n  " +
                                     "<Table1 />\n  <Table1 />\n  " +
                                     "<Table1 />\n  <Table1 />\n" +
                                     "</Registrants>"
      @rep_hash = {}
    end

    it "events parser should return empty hash" do
      @parser.parse_events(@ev_xml).should == @ev_hash
    end
    
    it "simple registration parser should return empty hash" do
      @parser.parse_simple_registrations(@sreg_xml).should == @sreg_hash
    end
    
    it "registration parser should return empty hash" do
      @parser.parse_registrations(@reg_xml).should == @reg_hash
    end
    
    it "report parser should return empty hash with only one element" do
      @parser.parse_report(@rep_xml_one_element).should == @rep_hash
    end
    
    it "report parser should return empty hash with many elements" do
      @parser.parse_report(@rep_xml_many_elements).should == @rep_hash
    end
  end
  
  describe "with no data" do
    before(:each) do
      @parser = RegonlineConnector::Parser.new
      @ev_xml = nil
      @ev_hash = nil
      @sreg_xml = nil
      @sreg_hash = nil
      @reg_xml = nil
      @reg_hash = nil
      @rep_xml = nil
      @rep_hash = nil
    end

    it "events parser should return nil" do
      @parser.parse_events(@ev_xml).should == @ev_hash
    end
    
    it "simple registration parser should return nil" do
      @parser.parse_simple_registrations(@sreg_xml).should == @sreg_hash
    end
    
    it "registration parser should return nil" do
      @parser.parse_registrations(@reg_xml).should == @reg_hash
    end
    
    it "report parser should return nil" do
      @parser.parse_report(@rep_xml).should == @rep_hash
    end
  end
end
