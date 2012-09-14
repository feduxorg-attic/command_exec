#encoding: utf-8

require 'popen4'
require 'smart_colored/extend'
require 'logger'
require 'json'
require 'psych'
require 'xmlsimple'

require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/string/filters'
require 'active_support/core_ext/hash/deep_merge'
require 'active_support/core_ext/hash/conversions'

require 'command_exec/formatter/array'
require 'command_exec/formatter/hash'
require 'command_exec/formatter/json'
require 'command_exec/formatter/yaml'
require 'command_exec/formatter/xml'
require 'command_exec/formatter/string'

require 'command_exec/version'
require 'command_exec/exceptions'
require 'command_exec/command'
require 'command_exec/process'

module CommandExec; end
