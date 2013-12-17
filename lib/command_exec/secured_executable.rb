# encoding: utf-8
module CommandExec
  class SecuredExecutable < Executable
    private

    # Hook executed after init
    def after_init
      @path_cleaner  = PathCleaner.new(secure_path: true, simple: true, pathname: true)
    end
  end
end
