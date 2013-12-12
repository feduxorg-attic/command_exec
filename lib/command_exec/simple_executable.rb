module CommandExec
  class SimpleExecutable < Executable

    private

    # Hook executed after init
    def after_init
      @path_cleaner  = PathCleaner.new( secure_path: false, simple: true, pathname: true )
    end

  end
end
