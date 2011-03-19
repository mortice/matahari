class Debriefing
  def initialize(expected_call_count = nil)
    @expected_call_count = expected_call_count
  end

  def matches?(subject)
    @subject = subject
    invocations_of_method = subject.invocations.select {|i| i[:method] == @call_to_verify}
    method_matched = invocations_of_method.size > 0 
    no_args = @args_to_verify.size == 0
    @matching_calls = invocations_of_method.select {|i| i[:args].flatten === @args_to_verify}.size
    if @expected_call_count
      checked_number_of_calls = true
      args_match = @matching_calls == @expected_call_count
    else
      args_match = @matching_calls > 0
    end
    matching = if checked_number_of_calls
                 args_match
               else
                 method_matched && no_args || args_match
               end

    if matching
      true
    else
      false
    end
  end

  def failure_message_for_should_not
    "Spy(:#{@subject.name}) expected not to receive :#{@call_to_verify} but received it #{prettify_times(@matching_calls)}"
  end

  def failure_message_for_should
    if @args_to_verify.size > 0
      "Spy(:#{@subject.name}) expected to receive :#{@call_to_verify}(#{@args_to_verify.map(&:inspect).join(", ")}) #{prettify_times(@expected_call_count)}, received #{prettify_times(@matching_calls)}"
    else
      "Spy(:#{@subject.name}) expected to receive :#{@call_to_verify} #{prettify_times(@expected_call_count)}, received #{prettify_times(@matching_calls)}"
    end
  end

  def method_missing(sym, *args, &block)
    @call_to_verify = sym
    @args_to_verify = args
    self
  end

  def prettify_times(times)
    case times
    when 1
      "once"
    when nil
      "once"
    when 2
      "twice"
    else
      "#{times} times"
    end
  end
  private :prettify_times
end
