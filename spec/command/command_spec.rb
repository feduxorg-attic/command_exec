require 'spec_helper'

describe Command do
  let(:logger) {Logger.new(StringIO.new)}
  #let(:logger) {Logger.new($stdout)}
  let(:log_level) {:info}
  let(:command) { Command.new(:echo , :logger => logger, :parameter => "hello world" , :error_keywords => %q[abc def], :working_directory => '/tmp' ) }

  context "command path" do
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
        command = Command.new('../bin/true')
        expect(command.path).to eq('/bin/true')
      end
    end

    it 'searches $PATH to find the command' do 
      command = Command.new(:true)
      expect(command.path).to eq("/bin/true")
    end

    it 'offers an option to change $PATH for the command execution' do
      command = Command.new(:echo_test, search_paths: [test_dir])
      expect(command.path).to eq(File.join(test_dir, 'echo_test'))
    end

  end

  context "checks" do

    it "checks if exec is executable" do
      command = Command.new('/bin/true')
      expect(command.executable?).to eq(true)

      command = Command.new('/etc/passwd')
      expect(command.executable?).to eq(false)
    end

    it "checks if exec exists" do
      command = Command.new('/bin/true')
      expect(command.exists?).to eq(true)

      command = Command.new('/usr/bin/true')
      expect(command.exists?).to eq(false)
    end

    it "checks if exec is valid (exists, executable, type = file)" do
      #does not exist
      command = Command.new('/usr/bin/true')
      expect(command.valid?).to eq(false)

      #is a directory not a file
      command = Command.new('/tmp')
      expect(command.valid?).to eq(false)

      #exists and is executable and is a file
      command = Command.new('/bin/true')
      expect(command.valid?).to eq(true)
    end

    it "raises an error if command is not executable" do
      command = Command.new('/etc/passwd', log_level: :silent)
      expect{command.send(:check_path)}.to raise_error CommandNotExecutable
    end

    it "raises an error if command does not exist" do
      command = Command.new('/usr/bin/true', log_level: :silent)
      expect{command.send(:check_path)}.to raise_error CommandNotFound
    end

    it "raises an error if command is not a file" do
      command = Command.new('/tmp', log_level: :silent)
      expect{command.send(:check_path)}.to raise_error CommandIsNotAFile
    end
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

  it "has special keywords indicating errors in stdout" do
    expect(command.error_keywords).to eq(%q[abc def])
  end

  it "can be used to construct a command string, which can be executed" do
    command = Command.new(:true, :parameter => "index.tex blub.tex", :options => "-a -b")
    expect(command.send(:to_s)).to eq("/bin/true -a -b index.tex blub.tex")
  end

  it "runs programms" do
    command = Command.new(:echo, :parameter => "output", :log_level => :silent )
    command.run
    expect(command.result).to eq(true)
  end

  it "returns the textual rep of a command" do
    expect(command.to_s).to eq('/bin/echo hello world')
  end

  it "execute existing programs" do
    command = Command.execute(:echo, :parameter => "output", :options => "-- -a -b", :log_level => :silent  )
    expect(command.result).to eq(true)
  end

  context 'output' do

    it "outputs nothing when empty" do
      log_file = StringIO.new
      stderr = StringIO.new
      stdout = StringIO.new

      result = command.send(:help_output,  { :log_file => log_file, :stderr => stderr , :stdout => stdout })
      expect(result).to eq( [] )

      result = command.send(:help_output,  {})
      expect(result).to eq( [] )

      result = command.send(:help_output )
      expect(result).to eq( [] )
    end

    it "outputs everything when all handles are defined" do
      log_file = StringIO.new( 'Error found' )
      stderr = StringIO.new('Error found')
      stdout = StringIO.new('Error found')

      result = command.send(:help_output,  { :log_file => log_file, :stderr => stderr , :stdout => stdout })
      expect(result).to eq( ["================== LOGFILE ==================", 
                             "Error found", 
                             "================== STDOUT  ==================",
                             "Error found", 
                             "================== STDERR  ==================", 
                             "Error found"] )
    end

    it "outputs stdout when defined" do
      log_file = StringIO.new
      stderr = StringIO.new
      stdout = StringIO.new('Error found')

    #  result = command.send(:help_output,  { :log_file => log_file, :stderr => stderr, :stdout => stdout })
    #  expect(result).to eq(["================== STDOUT  ==================", 
    #                        "Error found"] )

      
      stdout.rewind
      result = command.send(:help_output,  {:stdout => stdout })
      expect(result).to eq(["================== STDOUT  ==================", 
                            "Error found"] )
    end

    it "outputs log_file when defined" do
      log_file = StringIO.new('Error found')
      stderr = StringIO.new
      stdout = StringIO.new

      result = command.send(:help_output,  { :log_file => log_file, :stderr => stderr , :stdout => stdout })
      expect(result).to eq(["================== LOGFILE ==================",
                            "Error found" ])

      log_file.rewind
      result = command.send(:help_output,  { :log_file => log_file })
      expect(result).to eq(["================== LOGFILE ==================",
                            "Error found" ])
    end


    it "outputs stderr when defined" do
      log_file = StringIO.new
      stderr = StringIO.new('Error found')
      stdout = StringIO.new

      result = command.send(:help_output,  { :log_file => log_file, :stderr => stderr , :stdout => stdout })
      expect(result).to eq( [ "================== STDERR  ==================", 
                              "Error found"] )
      stderr.rewind
      result = command.send(:help_output,  { :stderr => stderr })
      expect(result).to eq( [ "================== STDERR  ==================", 
                              "Error found"] )
    end
  end

  it "finds errors in stdout" do
    expect(command.send(:error_in_string_found?, ['error'] , 'long string witherror inside' )).to eq(true)
    expect(command.send(:error_in_string_found?, ['long', 'inside'] , 'long string witherror inside' )).to eq(true)
    expect(command.send(:error_in_string_found?, ['error'] , 'long string with erro inside' )).to eq(false)
  end

  it "output a message" do
    expect(command.send(:message, false, 'Hello_world')).to eq( "\e[1m\e[1;31mFAILED\e[0m\e[0m\nHello_world" )
    expect(command.send(:message, true, 'Hello_world')).to eq("\e[1m\e[1;32mOK\e[0m\e[0m")
    expect(command.send(:message, true )).to eq("\e[1m\e[1;32mOK\e[0m\e[0m")
  end

  context "logging" do

    it "outputs only warnings when told to output those" do
      bucket = StringIO.new
      logger = Logger.new(bucket)

      command = Command.new(:logger_test ,
                            :logger => logger ,
                            :log_level => :warning,
                            :log_file => '/tmp/i_do_not_exist.log',
                            :search_paths => File.expand_path('test_data', File.dirname(__FILE__))).run

      expect(bucket.string['WARN']).to_not eq(nil)
    end

    it "is very verbose and returns a lot of output" do
      bucket = StringIO.new
      logger = Logger.new(bucket)
      Command.execute(:echo, :logger => logger ,:parameter => "output", :log_level => :debug)

      expect(bucket.string['DEBUG']).to_not eq(nil)
    end

    it "is silent and returns no output" do
      bucket = StringIO.new
      logger = Logger.new(bucket)
      Command.execute(:echo, :logger => logger ,:parameter => "output", :log_level => :silent)

      expect(bucket.string).to eq("")
    end

    it "use a log file if given" do
      application_log_file = create_tmp_file_with('command_exec_test', 'TEXT IN LOG') 

      bucket = StringIO.new
      logger = Logger.new(bucket)

      command = Command.new(:logger_test ,
                            :logger => logger ,
                            :log_file => application_log_file ,
                            :search_paths => File.expand_path('test_data', File.dirname(__FILE__))).run
    end

  end

  context "error handling" do
    it "considers status for error handling (default 0)" do
      command = Command.new(:exit_status_test, 
                            :search_paths => File.expand_path('test_data', File.dirname(__FILE__)),
                            :parameter => '1',
                            :error_detection_on => [:return_code], 
                           )
      command.run
      expect(command.result).to eq(false)
    end

    it "considers status for error handling (single value)" do
      command = Command.new(:exit_status_test, 
                            :search_paths => File.expand_path('test_data', File.dirname(__FILE__)),
                            :parameter => '1',
                            :error_detection_on => [:return_code], 
                            :error_indicators => { :allowed_return_code => [0] })
      command.run
      expect(command.result).to eq(false)
    end
    #command = Command.new(:true, :error_detection_on => [:stdout,:stderr,:status,:log_file])
  end

end
