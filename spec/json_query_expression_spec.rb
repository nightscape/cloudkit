require File.dirname(__FILE__) + '/spec_helper'

describe "A JSONQueryExpression" do

  describe "initialization from an escaped URI path" do

    it "should return a JSONQueryExpression object" do
      path = "/items/" + Rack::Utils.escape('[0:10]')
      expression = CloudKit::JSONQueryExpression.from_escaped_path(path)
      expression.should_not be_nil
      expression.is_a?(CloudKit::JSONQueryExpression).should be_true
    end

    it "should return nil if no JSONQueryExpression is found" do
      CloudKit::JSONQueryExpression.from_escaped_path('/items').should be_nil
    end

    it "should know its string form" do
      path = "/items/" + Rack::Utils.escape('[0:10]')
      expression = CloudKit::JSONQueryExpression.from_escaped_path(path)
      expression.string.should == '[0:10]'
    end

    it "should know its escaped string form" do
      path = "/items/" + Rack::Utils.escape('[0:10]')
      expression = CloudKit::JSONQueryExpression.from_escaped_path(path)
      expression.escaped_string.should == '%5B0%3A10%5D'
    end

  end

  it "should know the number of sub-expressions it contains" do
    path = "/items/" + Rack::Utils.escape('[=foo][0:10]')
    expression = CloudKit::JSONQueryExpression.from_escaped_path(path)
    expression.size.should == 2
  end

  it "should recognize array slice operators" do
    path = "/items/" + Rack::Utils.escape('[1:100][=foo][0:10]')
    expression = CloudKit::JSONQueryExpression.from_escaped_path(path)
    expression.slice_expressions.should == ['[1:100]', '[0:10]']
  end

  it "should respond to array index operators" do
    path = "/items/" + Rack::Utils.escape('[1:100][=foo][0:10]')
    expression = CloudKit::JSONQueryExpression.from_escaped_path(path)
    expression[1].should == '[=foo]'
  end

end
