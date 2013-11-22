#encoding: utf-8

require 'smart_colored/extend'
require 'json'
require 'psych'
require 'xmlsimple'
require 'open3'

require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/string/filters'
require 'active_support/core_ext/hash/deep_merge'
require 'active_support/core_ext/hash/conversions'

require 'fedux_org/stdlib/logging/logger'

require 'the_array_comparator'

require 'command_exec/version'
require 'command_exec/main'

#helper for fields
require 'command_exec/field_helper'

#output classes
require 'command_exec/formatter/array'
require 'command_exec/formatter/hash'
require 'command_exec/formatter/json'
require 'command_exec/formatter/yaml'
require 'command_exec/formatter/xml'
require 'command_exec/formatter/string'

#exceptions
require 'command_exec/exceptions'

#error detection
require 'command_exec/error_detector'
require 'command_exec/command'
require 'command_exec/process'

module CommandExec; end
