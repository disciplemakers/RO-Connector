require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "RegOnline" do
  describe "without credentials" do
    it "shouldn't instantiate" do
      lambda { roc_rusonline = RegonlineConnector::Client::RegistrationUpdateService.new }.should raise_exception(ArgumentError)
    end
  end
end