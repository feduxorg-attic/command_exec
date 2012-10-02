#encoding: utf-8

require 'spec_helper'

describe Command do
  let(:logger) {Logger.new(StringIO.new)}
  #let(:logger) {Logger.new($stdout)}
  let(:lib_log_level) {:info}
  let(:command) { Command.new(:echo , :logger => logger, :parameter => "hello world" , :error_keywords => %q[abc def], :working_directory => '/tmp' ) }

  context :public_api do
    test_dir = File.expand_path('test_data', File.dirname(__FILE__))

    it "supports relative paths" do
      Dir.chdir('spec/command') do
        command = Command.new('test_data/true_test')
        expect(command.path).to eq(File.join(test_dir, 'true_test'))
      end

      Dir.chdir test_dir do
        command = Command.new('./true_test')
        expect(command.path).to eq(File.join(test_dir, 'true_test'))
      end

      Dir.chdir '/tmp/' do
        command = Command.new('../usr/bin/true')
        expect(command.path).to eq('/usr/bin/true')
      end
    end

    it 'searches $PATH to find the command' do 
      command = Command.new(:true)
      expect(command.path).to eq("/usr/bin/true")
    end

    it 'offers an option to change $PATH for the command execution' do
      command = Command.new(:echo_test, search_paths: [test_dir])
      expect(command.path).to eq(File.join(test_dir, 'echo_test'))
    end

    it "checks if exec is executable" do
      command = Command.new('/usr/bin/true')
      expect(command.executable?).to eq(true)

      command = Command.new('/etc/passwd')
      expect(command.executable?).to eq(false)
    end

    it "checks if exec exists" do
      command = Command.new('/usr/bin/true')
      expect(command.exists?).to eq(true)

      command = Command.new('/usr/bin/does_not_exist')
      expect(command.exists?).to eq(false)
    end

    it "checks if exec is valid (exists, executable, type = file)" do
      #does not exist
      command = Command.new('/usr/bin/does_not_exist')
      expect(command.valid?).to eq(false)

      #is a directory not a file
      command = Command.new('/tmp')
      expect(command.valid?).to eq(false)

      #exists and is executable and is a file
      command = Command.new('/usr/bin/true')
      expect(command.valid?).to eq(true)
    end

    it "has parameter" do
      command = Command.new(:true, :parameter=>'parameter')
      expect(command.parameter).to eq('parameter')
    end

    it "has options" do
      expect(command.options).to eq('')
    end

    it "offers the possibility to change the working directory of the process without any side effects" do
      expect(command.working_directory).to eq('/tmp')

      #no side effects
      lambda { command.run }

      expect(Dir.pwd).to eq(File.expand_path('../..', File.dirname(__FILE__)))
    end

    it "can be used to construct a command string, which can be executed" do
      command = Command.new(:true, :parameter => "index.tex blub.tex", :options => "-a -b")
      expect(command.to_s).to eq("/usr/bin/true -a -b index.tex blub.tex")
    end

    it "runs programms" do
      command = Command.new(:echo, :parameter => "output", :lib_log_level => :silent )
      command.run
      expect(command.result.status).to eq(:success)
    end

    it "execute existing programs" do
      command = Command.execute(:echo, :parameter => "output", :options => "-- -a -b", :lib_log_level => :silent  )
      expect(command.result.status).to eq(:success)
    end

    it "is very verbose and returns a lot of output" do
      bucket = StringIO.new
      logger = Logger.new(bucket)
      Command.execute(:echo, :logger => logger ,:parameter => "output", :lib_log_level => :debug)

      expect(bucket.string['DEBUG']).to_not eq(nil)
    end

    it "is silent and returns no output" do
      # if you choose the system runner output of commands will be not suppressed"
      bucket = StringIO.new
      logger = Logger.new(bucket)
      Command.execute(:echo, :logger => logger ,:parameter => "output", :lib_log_level => :silent)

      expect(bucket.string).to eq("")
    end

    it "supports other log levels as well" do
      bucket = StringIO.new
      logger = Logger.new(bucket)

      Command.execute(:echo, :logger => logger ,:parameter => "output", :lib_log_level => :info)
      Command.execute(:echo, :logger => logger ,:parameter => "output", :lib_log_level => :warn)
      Command.execute(:echo, :logger => logger ,:parameter => "output", :lib_log_level => :error)
      Command.execute(:echo, :logger => logger ,:parameter => "output", :lib_log_level => :fatal)
      Command.execute(:echo, :logger => logger ,:parameter => "output", :lib_log_level => :unknown)
    end

    it "use a log file if given" do
      application_log_file = create_temp_file_with('command_exec_test', 'TEXT IN LOG') 

      bucket = StringIO.new
      logger = Logger.new(bucket)

      command = Command.new(:logger_test ,
                            :logger => logger ,
                            :log_file => application_log_file ,
                            :search_paths => File.expand_path('test_data', File.dirname(__FILE__))).run
    end

    it "outputs only warnings when told to output those" do
      bucket = StringIO.new
      logger = Logger.new(bucket)

      command = Command.new(:logger_test ,
                            :logger => logger ,
                            :lib_log_level => :warn,
                            :log_file => '/tmp/i_do_not_exist.log',
                            :search_paths => File.expand_path('test_data', File.dirname(__FILE__))).run

      expect(bucket.string['WARN']).to_not eq(nil)
    end

    it "considers status for error handling (default 0)" do
      command = Command.new(:exit_status_test, 
                            :search_paths => File.expand_path('test_data', File.dirname(__FILE__)),
                            :parameter => '1',
                            :lib_log_level => :silent,
                            :error_detection_on => [:return_code], 
                           )
      command.run
      expect(command.result.status).to eq(:failed)
    end

    it "considers status for error handling (single value as array)" do
      command = Command.new(:exit_status_test, 
                            :search_paths => File.expand_path('test_data', File.dirname(__FILE__)),
                            :parameter => '1',
                            :lib_log_level => :silent,
                            :error_detection_on => [:return_code], 
                            :error_indicators => { :allowed_return_code => [0] })
      command.run
      expect(command.result.status).to eq(:failed)
    end

    it "considers status for error handling (single value as symbol)" do
      command = Command.new(:exit_status_test, 
                            :search_paths => File.expand_path('test_data', File.dirname(__FILE__)),
                            :parameter => '1',
                            :lib_log_level => :silent,
                            :error_detection_on => :return_code, 
                            :error_indicators => { :allowed_return_code => [0] })
      command.run
      expect(command.result.status).to eq(:failed)
    end

    it "considers status for error handling (single value)" do
      command = Command.new(:exit_status_test, 
                            :search_paths => File.expand_path('test_data', File.dirname(__FILE__)),
                            :parameter => '0',
                            :lib_log_level => :silent,
                            :error_detection_on => [:return_code], 
                            :error_indicators => { :allowed_return_code => [0,2] })
      command.run
      expect(command.result.status).to eq(:success)

      command = Command.new(:exit_status_test, 
                            :search_paths => File.expand_path('test_data', File.dirname(__FILE__)),
                            :parameter => '2',
                            :lib_log_level => :silent,
                            :error_detection_on => [:return_code], 
                            :error_indicators => { :allowed_return_code => [0,2] })
      command.run
      expect(command.result.status).to eq(:success)
    end

    it "considers stderr for error handling" do
      command = Command.new(:stderr_test, 
                            :search_paths => File.expand_path('test_data', File.dirname(__FILE__)),
                            :lib_log_level => :silent,
                            :error_detection_on => :stderr, 
                            :error_indicators => { :forbidden_words_in_stderr => %w{error} })
      command.run
      expect(command.result.status).to eq(:failed)
    end

    it "considers stderr for error handling but can make exceptions" do
      command = Command.new(:stderr_test, 
                            :search_paths => File.expand_path('test_data', File.dirname(__FILE__)),
                            :lib_log_level => :silent,
                            :error_detection_on => :stderr, 
                            :error_indicators => { :forbidden_words_in_stderr => %w{error}, :allowed_words_in_stderr =>  ["error. execution failed"]})
      command.run
      expect(command.result.status).to eq(:success)
    end

    it "considers stdout for error handling" do
      command = Command.new(:stdout_test, 
                            :search_paths => File.expand_path('test_data', File.dirname(__FILE__)),
                            :lib_log_level => :silent,
                            :error_detection_on => :stdout, 
                            :error_indicators => { :forbidden_words_in_stdout => %w{error} })
      command.run
      expect(command.result.status).to eq(:failed)
    end

    
    it "removes newlines from stdout" do
      #same for stderr
      command = Command.new(:stdout_multiple_lines_test, 
                            :search_paths => File.expand_path('test_data', File.dirname(__FILE__)),
                            :lib_log_level => :silent,
                            :error_detection_on => :stdout, 
                            :error_indicators => { :forbidden_words_in_stdout => %w{error} })
      command.run
      expect(command.result.stdout).to eq(["error. execution failed", "error. execution failed"])
    end

    it "considers log file for error handling" do
      temp_file = create_temp_file_with('log_file_test', 'error, huh, what goes on' )

      command = Command.new(:log_file_test, 
                            :search_paths => File.expand_path('test_data', File.dirname(__FILE__)),
                            :lib_log_level => :silent,
                            :log_file => temp_file,
                            :error_detection_on => :log_file, 
                            :error_indicators => { :forbidden_words_in_log_file => %w{error} })
      command.run
      expect(command.result.status).to eq(:failed)
    end

    it "returns the result of command execution as process object (defaults to :return_process_information)" do
      command = Command.new(:output_test, 
                            :search_paths => File.expand_path('test_data', File.dirname(__FILE__)),
                            :lib_log_level => :silent,
                            :error_detection_on => :return_code, 
                            :error_indicators => { :allowed_return_code => [ 0 ]})
      command.run
      expect(command.result.class).to eq(CommandExec::Process)
    end

    it "returns the result of command execution as process object" do
      command = Command.new(:output_test, 
                            :search_paths => File.expand_path('test_data', File.dirname(__FILE__)),
                            :lib_log_level => :silent,
                            :on_error_do => :return_process_information,
                            :error_detection_on => :return_code, 
                            :error_indicators => { :allowed_return_code => [ 0 ]})
      command.run
      expect(command.result.class).to eq(CommandExec::Process)
    end

    it "does nothing on error if told so" do
      command = Command.new(:raise_error_test, 
                            :search_paths => File.expand_path('test_data', File.dirname(__FILE__)),
                            :lib_log_level => :silent,
                            :on_error_do => :nothing,
                            :error_detection_on => :return_code, 
                            :error_indicators => { :allowed_return_code => [ 0 ]})
      expect{command.run}.to_not raise_error
      expect{command.run}.to_not throw_symbol
    end

    it "raises an exception" do
      command = Command.new(:raise_error_test, 
                            :search_paths => File.expand_path('test_data', File.dirname(__FILE__)),
                            :lib_log_level => :silent,
                            :on_error_do => :raise_error,
                            :error_detection_on => :return_code, 
                            :error_indicators => { :allowed_return_code => [ 0 ]})
      expect{command.run}.to raise_error(CommandExec::Exceptions::CommandExecutionFailed)

      command = Command.new(:not_raise_error_test, 
                            :search_paths => File.expand_path('test_data', File.dirname(__FILE__)),
                            :lib_log_level => :silent,
                            :on_error_do => :raise_error,
                            :error_detection_on => :return_code, 
                            :error_indicators => { :allowed_return_code => [ 0 ]})
      expect{command.run}.to_not raise_error
    end

    it "throws an error" do
      command = Command.new(:throw_error_test, 
                            :search_paths => File.expand_path('test_data', File.dirname(__FILE__)),
                            :lib_log_level => :silent,
                            :on_error_do => :throw_error,
                            :error_detection_on => :return_code, 
                            :error_indicators => { :allowed_return_code => [ 0 ]})
      expect{command.run}.to throw_symbol(:command_execution_failed)

      command = Command.new(:not_throw_error_test, 
                            :search_paths => File.expand_path('test_data', File.dirname(__FILE__)),
                            :lib_log_level => :silent,
                            :on_error_do => :throw_error,
                            :error_detection_on => :return_code, 
                            :error_indicators => { :allowed_return_code => [ 0 ]})
      expect{command.run}.to_not throw_symbol
    end

    it "support open3 as runner" do
      #implicit via default value (open3)
      command = Command.new(:runner_open3_test,
                            :search_paths => File.expand_path('test_data', File.dirname(__FILE__)),
                            :lib_log_level => :silent,
                            :error_detection_on => :return_code, 
                            :error_indicators => { :allowed_return_code => [ 0 ]})
      command.run
      expect(command.result.status).to eq(:success)

      #or explicit
      command = Command.new(:runner_open3_test,
                            :search_paths => File.expand_path('test_data', File.dirname(__FILE__)),
                            :run_via => :open3,
                            :lib_log_level => :silent,
                            :error_detection_on => :return_code, 
                            :error_indicators => { :allowed_return_code => [ 0 ]})
      command.run
      expect(command.result.status).to eq(:success)
    end

    it "support system as runner" do
      command = Command.new(:runner_system_test,
                            :search_paths => File.expand_path('test_data', File.dirname(__FILE__)),
                            :run_via => :system,
                            :lib_log_level => :silent,
                            :error_detection_on => :return_code, 
                            :error_indicators => { :allowed_return_code => [ 0 ]})
      command.run
      expect(command.result.status).to eq(:success)
    end

    it "has a default runner: open3" do
      command = Command.new(:runner_system_test,
                            :search_paths => File.expand_path('test_data', File.dirname(__FILE__)),
                            :run_via => :unknown_runner,
                            :lib_log_level => :silent,
                            :error_detection_on => :return_code, 
                            :error_indicators => { :allowed_return_code => [ 0 ]})
      command.run
      expect(command.result.status).to eq(:success)
    end

    it "find errors beyond newlines in the string" do
      command = CommandExec::Command.new( :echo ,
                                         :options => '-e',
                                         :parameter => "\"wow, a test. That's great.\nBut an error occured in this line\"",
                                         :error_detection_on => [:stdout],
                                         :error_indicators => {
                                           :forbidden_words_in_stdout => %w{ error }
                                         },
                                        )
                                        command.run
                                        expect(command.result.status).to eq(:failed)
    end
  end

  context :private_api do
    it "raises an error if command is not executable" do
      command = Command.new('/etc/passwd', lib_log_level: :silent)
      expect{command.send(:check_path)}.to raise_error CommandNotExecutable
    end

    it "raises an error if command does not exist" do
      command = Command.new('/usr/bin/does_not_exist', lib_log_level: :silent)
      expect{command.send(:check_path)}.to raise_error CommandNotFound
    end

    it "raises an error if command is not a file" do
      command = Command.new('/tmp', lib_log_level: :silent)
      expect{command.send(:check_path)}.to raise_error CommandIsNotAFile
    end

    it "finds errors in string" do
      expect(command.send(:error_occured?, ['error'] , [], ['long string witherrorinside'] )).to eq(true)
      expect(command.send(:error_occured?, ['error', 'inside'] , [], ['long string with error inside'] )).to eq(true)
      expect(command.send(:error_occured?, ['error'] , [], ['long string with no erro"r" inside'] )).to eq(false)

      expect(command.send(:error_occured?, ['error'] , ['long string with error inside but an exception defined'], ['long string with error inside but an exception defined'] )).to eq(false)
      expect(command.send(:error_occured?, ['error'] , ['substring exception defined'], ['long string with error inside but a substring exception defined'] )).to eq(false)
    end
  end
end
