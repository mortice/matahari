require 'spec_helper'
describe Matahari::InvocationMatcher do
  it "matches simple invocations" do
    #we have to use rspec mocks here because testing matahari with matahari
    #makes my brain hurt

    subject = mock(:subject)
    invocation_matcher = Matahari::InvocationMatcher.new

    subject.should_receive(:invocations).and_return([Matahari::Invocation.new(:one)])

    invocation_matcher.one

    invocation_matcher.matches?(subject).should be_true
  end

  it "matches invocations based on arguments" do
    subject = mock(:subject)
    correct_invocation_matcher = Matahari::InvocationMatcher.new
    incorrect_invocation_matcher = Matahari::InvocationMatcher.new

    subject.should_receive(:invocations).twice.and_return([Matahari::Invocation.new(:one, "Hello", "goodbye")])

    correct_invocation_matcher.one("Hello", "goodbye")
    incorrect_invocation_matcher.one("Hello", "goodbye", "Hello again")

    correct_invocation_matcher.matches?(subject).should be_true
    incorrect_invocation_matcher.matches?(subject).should be_false
  end

  it "matches arguments which are arrays" do
    subject = mock(:subject)
    invocation_matcher = Matahari::InvocationMatcher.new

    subject.should_receive(:invocations).and_return([Matahari::Invocation.new(:one, [2, 3, 4])])

    invocation_matcher.one([2, 3, 4])
    invocation_matcher.matches?(subject).should be_true
  end

  it "gives a failure message for should when method not called" do
    subject = mock(:subject)
    invocation_matcher = Matahari::InvocationMatcher.new

    subject.should_receive(:invocations).and_return([Matahari::Invocation.new(:one)])
    subject.should_receive(:name).and_return(:subject)

    invocation_matcher.two

    invocation_matcher.matches?(subject).should be_false

    invocation_matcher.failure_message_for_should.should == "Spy(:subject) expected to receive :two once, received 0 times"
  end

  it "gives a failure message for should when method called with wrong arguments" do
    subject = mock(:subject)
    invocation_matcher = Matahari::InvocationMatcher.new

    subject.should_receive(:invocations).and_return([Matahari::Invocation.new(:one)])
    subject.should_receive(:name).and_return(:subject)

    invocation_matcher.one("Hello")

    invocation_matcher.matches?(subject).should be_false

    invocation_matcher.failure_message_for_should.should ==  "Spy(:subject) expected to receive :one(\"Hello\") once, received 0 times"
  end

  it "gives a failure message for should when method called wrong number of times" do
    subject = mock(:subject)
    invocation_matcher = Matahari::InvocationMatcher.new(2.times)

    subject.should_receive(:invocations).and_return([Matahari::Invocation.new(:one)])
    subject.should_receive(:name).and_return(:subject)

    invocation_matcher.one

    invocation_matcher.matches?(subject).should be_false

    invocation_matcher.failure_message_for_should.should == "Spy(:subject) expected to receive :one twice, received once"
  end

  it "gives a failure message for should not" do
    subject = mock(:subject)
    invocation_matcher = Matahari::InvocationMatcher.new

    subject.should_receive(:invocations).and_return([Matahari::Invocation.new(:two)])
    subject.should_receive(:name).and_return(:subject)

    invocation_matcher.two

    invocation_matcher.matches?(subject).should be_true

    invocation_matcher.failure_message_for_should_not.should == "Spy(:subject) expected not to receive :two but received it once"
  end
end
