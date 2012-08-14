require 'spec_helper'

describe Command do
  let(:logger) {Logger.new(StringIO.new)}
  #let(:logger) {Logger.new($stdout)}
  let(:log_level) {:info}
  let(:command) { Command.new(:echo , :log_level => :silent, :logger => logger, :parameter => "hello world" , :error_keywords => %q[abc def], :working_directory => '/tmp' ) }

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
      command = Command.new('/etc/passwd')
      expect{command.send(:check_path)}.to raise_error CommandNotExecutable
    end

    it "raises an error if command does not exist" do
      command = Command.new('/usr/bin/true')
      expect{command.send(:check_path)}.to raise_error CommandNotFound
    end

    it "raises an error if command is not a file" do
      command = Command.new('/tmp')
      expect{command.send(:check_path)}.to raise_error CommandIsNotAFile
    end
  end

  it "has parameter" do
    expect(command.parameter).to eq('hello world')
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
    command = Command.new(:pdflatex, :log_level => :silent, :logger => logger, :parameter => "index.tex blub.tex", :options => "-a -b")
    expect(command.send(:build_cmd_string)).to eq("/usr/bin/pdflatex -a -b index.tex blub.tex")
  end

  it "runs programms" do
    command.run
    expect(command.result).to eq(true)
  end

  it "returns the textual rep of a command" do
    expect(command.to_txt).to eq('/bin/echo hello world')
  end

  it "execute existing programs" do
    command = Command.execute(:echo, :log_level => :silent, :logger => logger ,:parameter => "index.tex blub.tex", :options => "-- -a -b")
    expect(command.result).to eq(true)
  end
  
  it "does not execute non-existing programs" do
    command = Command.execute(:grep, :log_level => :silent, :logger => logger, :parameter => "index.tex blub.tex", :options => "-- -a -b")
    expect(command.result).to eq(false)
  end

  it "checks if errors have happend during execution" do
    command = Command.new(:echo1, :log_level => :silent, :logger => logger, :parameter => "index.tex blub.tex", :options => "-- -a -b")
    expect { command.run }.to raise_error CommandNotFound
  end

  it "decides which output should be returned to the user" do
    log_file = StringIO.new
    log_file << 'Error in ... found'

    stderr = StringIO.new
    stderr << 'Error found'

    stdout = StringIO.new
    stdout << 'Error found'

    #result = command.send(:help_logger)({ :error_in_exec => true , :error_in_stdout => false} , { :log_file => log_file, :stderr => stderr , :stdout => stdout })
    result = command.send(:help_output, { :error_in_exec => true , :error_in_stdout => false} , { :log_file => log_file, :stderr => stderr , :stdout => stdout })
    expect(result).to eq( ["================== LOGFILE ================== ", 
                          "Error in ... found", 
                          "================== STDOUT ================== ",
                          "Error found", 
                          "================== STDERR ================== ", 
                          "Error found"] )

    result = command.send(:help_output, { :error_in_exec => false , :error_in_stdout => true} , { :log_file => log_file, :stderr => stderr , :stdout => stdout })
    expect(result).to eq(["================== STDOUT ================== ", 
                          "Error found"] )

    result = command.send(:help_output, { :error_in_exec => true , :error_in_stdout => true} , { :log_file => log_file, :stderr => stderr , :stdout => stdout })
    expect(result).to eq(["================== LOGFILE ================== ",
                      "Error in ... found",
                      "================== STDOUT ================== ",
                      "Error found",
                      "================== STDERR ================== ",
                      "Error found"])


    result = command.send(:help_output, { :error_in_exec => false , :error_in_stdout => false} , { :log_file => log_file, :stderr => stderr , :stdout => stdout })
    expect(result).to eq([])

  end

  it "finds errors in stdout" do
    expect(command.send(:error_in_string_found?, ['error'] , 'long string witherror inside' )).to eq(true)
    expect(command.send(:error_in_string_found?, ['long', 'inside'] , 'long string witherror inside' )).to eq(true)
    expect(command.send(:error_in_string_found?, ['error'] , 'long string with erro inside' )).to eq(false)
  end

  it "output a message" do
    expect(command.send(:message, false, 'Hello_world')).to eq( "\e[1m\e[31mFAILED\e[0m\e[0m\nHello_world" )
    expect(command.send(:message, true, 'Hello_world')).to eq("\e[1m\e[32mOK\e[0m\e[0m")
    expect(command.send(:message, true )).to eq("\e[1m\e[32mOK\e[0m\e[0m")
  end

  context "logging" do

    it "outputs only warnings when told to output those" do
      bucket = StringIO.new
      logger = Logger.new(bucket)
      Command.execute(:echo, :logger => logger ,:parameter => "output", :log_file => '/tmp/i_do_not_exist.log', :log_level => :warning)

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

    # not completed
    it "use a log file if given" do
      application_log_file = create_tmp_file_with('command_exec_test', 'TEXT IN LOG') 

      Dir.chdir File.expand_path('test_data', File.dirname(__FILE__)) do
        output = capture_stdout do
          Command.new('logger_test' , :logger => logger , :log_file => application_log_file ).run
        end

        expect(output['TEXT IN LOG']).to_not eq(nil)
      end

    end
  end

  
end
