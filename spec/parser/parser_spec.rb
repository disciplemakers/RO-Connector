require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Parser" do
  describe "without credentials" do
    it "shouldn't instantiate" do
      lambda { roc_client = RegonlineConnector::Client.new }.should raise_exception(ArgumentError)
    end
  end
end
