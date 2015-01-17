# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Ven 2015-01-16 14:20 svarrette>
################################################################################

require 'thor'
require 'falkorlib/cli/init'

module FalkorLib
  module CLI
    class Runner < ::Thor
      class_option :verbose,
                   :aliases => '-v',
                   :type => :boolean,
                   :default => false,
                   :desc => "Verbose mode"

      # class_option :config,
      #              :type => :string,
      #              :desc => "Configuration file.  accepts ENV $FALKOR_CONFIG_FILE",
      #              :default => ENV["FALKOR_CONFIG_FILE"] || "~/.falkor.rc"

                   

                   
      ###### info ######
      desc "info [options]", "Print various configuration information"
      def info
        puts "info"
        puts options.to_yaml
      end # info

      
      
      # ####### init ########
      # desc "init TYPE", "Initialize the directory PATH with FalkorLib's template(s)"
      # subcommand "init", FalkorLib::CLI::Init
      #register FalkorLib::CLI::Init, 'init', 'init <TYPE>', "Initialize the directory PATH with FalkorLib's template(s)"

      
    end # class Runner
  end
end 
