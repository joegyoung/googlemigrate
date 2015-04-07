require 'google/api_client'
require 'net/http'
require "base64"
require 'fileutils'




class Object
  def blank?
    respond_to?(:empty?) ? empty? : !self
  end

  def present?
    !blank?
  end
end

require File.dirname(__FILE__)+"/google/googlefile.class.rb"
require File.dirname(__FILE__)+"/google/googleapi.class.rb"

require File.dirname(__FILE__)+"/filedir.class.rb"



