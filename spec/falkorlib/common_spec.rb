require 'spec_helper'
require 'tempfile'

describe FalkorLib::Common do

    include FalkorLib::Common

	#############################################
    context "Test (common) printing functions" do

        @print_test_conf = {
            :info => {
                :color  => :green,
				:prefix => "[INFO]",
            },
            :warning => {
                :color  => :cyan,
                :prefix => "/!\\ WARNING:",
            },
            :error => {
                :color  => :red,
                :prefix => "*** ERROR ***",
            }
        }

        # Check the color functions
        @print_test_conf.values.collect{ |e| e[:color] }.each do |color|
			it "##{color} - check #{color} text" do
                STDOUT.should_receive(:puts).with(send("#{color}", "#{color} text"))
                puts send("#{color}", "#{color} text")
            end
        end

        # Check the prining messages
        @print_test_conf.each do |method,conf|
			it "##{method} - put a #{method} message" do
                ((method == :error) ? STDERR : STDOUT).should_receive(:puts).with(send("#{conf[:color]}", "#{conf[:prefix]} #{method} text"))
                if (method == :error)
                    lambda {
                        send("#{method}", "#{method} text")
                    }.should raise_error #(SystemExit)
                else
                    send("#{method}", "#{method} text")
                end
            end
        end

        # Check the ask function
        ['', 'default'].each do |default_answer|
            @query = "Am I a query"
            it "#ask - ask '#{@query}' with default answer '#{default_answer}' and no answer" do
                STDIN.should_receive(:gets).and_return('')
                results = capture(:stdout) {
                    answer = ask(@query, default_answer)
                    if default_answer.empty?
                        answer.should be_empty
                    else
                        answer.should == default_answer
                    end
                }
                results.should =~ /#{@query}/;
                unless default_answer.empty?
                    results.should =~ /Default: #{default_answer}/;
                end
            end
        end

        # Check the really_continue? function
        [ '', 'Yes', 'y', 'Y', 'yes' ].each do |answer|
            it "#really_continue? - should really continue after answer '#{answer}'" do
                STDIN.should_receive(:gets).and_return(answer)
                results = capture(:stdout) { really_continue? }
                results.should =~ /=> Do you really want to continue/;
                results.should =~ /Default: Yes/;
            end
            next if answer.empty?
            it "#really_continue? - should really continue (despite default answer 'No') after answer '#{answer}'" do
                STDIN.should_receive(:gets).and_return(answer)
                results = capture(:stdout) { really_continue?('No') }
                results.should =~ /=> Do you really want to continue/;
                results.should =~ /Default: No/;
            end
        end

        [ '', 'No', 'n', 'N', 'no' ].each do |answer|
            it "#really_continue? - should not continue (despite default answer 'No') and exit after answer '#{answer}'" do
                STDIN.should_receive(:gets).and_return(answer)
                results = capture(:stdout) {
                    lambda{
                        really_continue?('No')
                    }.should raise_error (SystemExit)
                }
                results.should =~ /=> Do you really want to continue/;
                results.should =~ /Default: No/;
            end
            next if answer.empty?
            it "#really_continue? - should not continue and exit after answer '#{answer}'" do
                STDIN.should_receive(:gets).and_return(answer)
                results = capture(:stdout) {
                    lambda{
                        really_continue?
                    }.should raise_error (SystemExit)
                }
                results.should =~ /=> Do you really want to continue/;
                results.should =~ /Default: Yes/;
            end
        end

        # Check the command? function
        [ 'sqgfyueztruyjf', 'ruby' ].each do |command|
            it "#command? - check the command '#{command}'" do
                command?(command).should ((command == 'ruby') ? be_true : be_false)
            end
        end
   end
	
	#############################################
    context "Test (common) YAML functions" do

		it "#load_config - load the correct hash from YAML" do
			file_config = {:domain => "foo.com", :nested => { 'a1' => 2 }}                              
			YAML.stub(:load_file).and_return(file_config)  
			loaded = load_config('toto')
			loaded.should == file_config
		end 

		it "#store_config - should store the correct hash to YAML" do
			file_config = {:domain => "foo.com", :nested => { 'a1' => 2 }}    
			f = Tempfile.new('toto')
			store_config(f.path, file_config)
			copy_file_config = YAML::load_file(f.path)
			copy_file_config.should == file_config
		end 

	end 

end
