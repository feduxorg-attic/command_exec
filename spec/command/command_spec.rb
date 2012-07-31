require 'spec_helper'

describe Command do
  let(:logger) {Logger.new(StringIO.new)}
  #let(:logger) {Logger.new($stdout)}
  let(:log_level) {:info}
  let(:command) { Command.new(:echo , :log_level => :silent, :logger => logger, :parameter => "hello world" , :error_keywords => %q[abc def], :working_directory => '/tmp' ) }

  it "has a path" do
    command.path.should == '/bin/echo'
  end

  it "has parameter" do
    command.parameter.should == 'hello world'
  end

  it "has options" do
    command.options.should == ''
  end

  it "offers the possibility to change the working directory of the process" do
    command.working_directory.should == '/tmp'

    Dir.pwd.should == File.expand_path('../..', File.dirname(__FILE__))
    lambda { command.run }
    Dir.pwd.should == File.expand_path('../..', File.dirname(__FILE__))
  end

  it "has special keywords indicating errors in stdout" do
    command.error_keywords.should == %q[abc def]
  end

  it "can be used to construct a command string, which can be executed" do
    command = Command.new(:pdflatex, :log_level => :silent, :logger => logger, :parameter => "index.tex blub.tex", :options => "-a -b")
    command.send(:build_cmd_string).should == "/usr/bin/pdflatex -a -b index.tex blub.tex"
  end

  it "runs programms" do
    command.run
    command.result.should == true
  end

  it "returns the textual rep of a command" do
    command.to_txt.should == '/bin/echo hello world'
  end

  it "execute existing programs" do
    command = Command.execute(:echo, :log_level => :silent, :logger => logger ,:parameter => "index.tex blub.tex", :options => "-- -a -b")
    command.result.should == true
  end
  
  it "does not execute non-existing programs" do
    command = Command.execute(:grep, :log_level => :silent, :logger => logger, :parameter => "index.tex blub.tex", :options => "-- -a -b")
    command.result.should == false
  end

  it "checks if errors have happend during execution" do
    lambda { Command.new(:echo1, :log_level => :silent, :logger => logger, :parameter => "index.tex blub.tex", :options => "-- -a -b") }.should raise_error CommandNotFound
  end

  it "decides which output should be returned to the user" do
    logfile = StringIO.new
    logfile << 'Error in ... found'

    stderr = StringIO.new
    stderr << 'Error found'

    stdout = StringIO.new
    stdout << 'Error found'

    #result = command.send(:help_logger)({ :error_in_exec => true , :error_in_stdout => false} , { :logfile => logfile, :stderr => stderr , :stdout => stdout })
    result = command.send(:help_output, { :error_in_exec => true , :error_in_stdout => false} , { :logfile => logfile, :stderr => stderr , :stdout => stdout })
    result.should == ["================== LOGFILE ================== ", "Error in ... found", "================== STDOUT ================== ", "Error found", "================== STDERR ================== ", "Error found"]

    result = command.send(:help_output, { :error_in_exec => false , :error_in_stdout => true} , { :logfile => logfile, :stderr => stderr , :stdout => stdout })
    result.should == ["================== STDOUT ================== ", "Error found"]

    result = command.send(:help_output, { :error_in_exec => true , :error_in_stdout => true} , { :logfile => logfile, :stderr => stderr , :stdout => stdout })
    result.should == ["================== LOGFILE ================== ", "Error in ... found", "================== STDOUT ================== ", "Error found", "================== STDERR ================== ", "Error found"]


    result = command.send(:help_output, { :error_in_exec => false , :error_in_stdout => false} , { :logfile => logfile, :stderr => stderr , :stdout => stdout })
    result.should == []

  end

  it "finds errors in stdout" do
    command.send(:error_in_string_found?, ['error'] , 'long string witherror inside' ).should == true
    command.send(:error_in_string_found?, ['long', 'inside'] , 'long string witherror inside' ).should == true
    command.send(:error_in_string_found?, ['error'] , 'long string with erro inside' ).should == false
  end

  it "output a message" do
    command.send(:message, false, 'Hello_world').should == "\e[1m\e[31mFAILED\e[0m\e[0m\nHello_world"
    command.send(:message, true, 'Hello_world').should == "\e[1m\e[32mOK\e[0m\e[0m"
    command.send(:message, true ).should == "\e[1m\e[32mOK\e[0m\e[0m"
  end

  it "is very verbose and returns a lot of output" do
    bucket = StringIO.new
    logger = Logger.new(bucket)
    Command.execute(:echo, :logger => logger ,:parameter => "index.tex blub.tex", :options => "-- -a -b" , :log_level => :debug)

    bucket.string.should =~ /OK/
  end

  it "is silent and returns no output" do
    bucket = StringIO.new
    logger = Logger.new(bucket)
    Command.execute(:echo, :logger => logger ,:parameter => "index.tex blub.tex", :options => "-- -a -b" , :log_level => :silent)

    bucket.string.should == ""
  end

  # not completed
  it "use a log file if given" do
    application_log_file = create_tmp_file_with('command_exec_test', 'TEXT IN LOG') 

    Dir.chdir File.expand_path('test_data', File.dirname(__FILE__)) do
      output = capture_stdout do
        Command.new('logger_test' , :logger => logger ,:parameter => "index.tex blub.tex", :options => "-- -a -b" , :logfile => application_log_file ).run
      end
      expect(output['TEXT IN LOG']).to_not be(nil)
    end

  end
  
  it "resolves path name" do
    command.send(:resolve_cmd_name, :true).should == "/bin/true"
    command.send(:resolve_cmd_name, "/bin/true").should == "/bin/true"

    Dir.chdir File.expand_path('test_data', File.dirname(__FILE__)) do
      command.send(:resolve_cmd_name, "./true_test").should == "/home/d/work/projects/ruby-command_exec/spec/command/test_data/true_test"
    end

    Dir.chdir '/tmp/' do
      command.send(:resolve_cmd_name, "../bin/true").should == "/bin/true"
    end

    command.send(:resolve_cmd_name, :echo).should == "/bin/echo"
    command.send(:resolve_cmd_name, :echo_test, [File.join(File.dirname(__FILE__), 'test_data' )]).should == "/home/d/work/projects/ruby-command_exec/spec/command/test_data/echo_test"
    lambda{command.send(:resolve_cmd_name, "abc")}.should raise_error Exceptions::CommandNotFound 
    
    Dir.chdir('spec/command') do
      command.send(:resolve_cmd_name, "test_data/true_test").should == "/home/d/work/projects/ruby-command_exec/spec/command/test_data/true_test"
    end
  end
end
