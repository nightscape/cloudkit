require 'rubygems'
require 'erb'
require 'json'
require 'digest/md5'
require 'openid'
require 'time'
require 'uuid'
require 'rack'
require 'johnson'
require 'oauth'
require 'oauth/consumer'
require 'oauth/request_proxy/rack_request'
require 'oauth/server'
require 'oauth/signature'
require 'cloudkit/constants'
require 'cloudkit/exceptions'
require 'cloudkit/util'
require 'cloudkit/uri'
require 'cloudkit/store/json_query_expression'
require 'cloudkit/store/memory_table'
require 'cloudkit/store/resource'
require 'cloudkit/store/response'
require 'cloudkit/store/response_helpers'
require 'cloudkit/store'
require 'cloudkit/flash_session'
require 'cloudkit/oauth_filter'
require 'cloudkit/oauth_store'
require 'cloudkit/openid_filter'
require 'cloudkit/openid_store'
require 'cloudkit/rack/builder'
require 'cloudkit/rack/router'
require 'cloudkit/request'
require 'cloudkit/service'
require 'cloudkit/user_store'

include CloudKit::Constants

module CloudKit
  VERSION = '0.11.1'

  # Sets up the storage adapter. Defaults to development-time
  # CloudKit::MemoryTable. Also supports Rufus Tokyo Table instances. See the
  # examples directory for Cabinet and Tyrant Table examples.
  def self.setup_storage_adapter(adapter_instance=nil)
    @storage_adapter = adapter_instance || CloudKit::MemoryTable.new
  end

  # Return the shared storage adapter.
  def self.storage_adapter
    @storage_adapter
  end

  def self.javascript_runtime
    unless @javascript_runtime
      @javascript_runtime = Johnson::Runtime.new
      libs = 'window = {};' # fake top level JS namespace
      prefix = File.expand_path(File.dirname(__FILE__)) + '/cloudkit/store/'
      ['json2.js', 'query.js'].each do |file|
        File.open(prefix + file, 'r') { |f| libs << f.read }
      end
      @javascript_runtime.evaluate(libs);
    end
    @javascript_runtime
  end
end

class Object

  # Execute a method if it exists.
  def try(method) # via defunkt
    send method if respond_to? method
  end
end

class Hash

  # For each key in 'other' that has a non-nil value, merge it into the current
  # Hash.
  def filter_merge!(other={})
    other.each_pair{|k,v| self.merge!(k => v) unless v.nil?}
    self
  end

  # Change the key 'oldkey' to 'newkey'
  def rekey!(oldkey, newkey)
    if self.has_key? oldkey
      self[newkey] = self.delete(oldkey)
    end
    nil
  end

  # Return a new Hash, excluding the specified list of keys.
  def excluding(*keys)
    trimmed = self.dup
    keys.each{|k| trimmed.delete(k)}
    trimmed
  end
end

class Array

  # Return a new Array, excluding the specified list of values.
  def excluding(*keys)
    trimmed = self.dup
    trimmed - keys
  end
end
