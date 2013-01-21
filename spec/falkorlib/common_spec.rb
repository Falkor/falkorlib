require 'spec_helper'

describe FalkorLib do

    include FalkorLib::Common

    context "test printing functions" do

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
            it "should check a #{color} text" do
                STDOUT.should_receive(:puts).with(send("#{color}", "#{color} text"))
                puts send("#{color}", "#{color} text")
            end
        end

		# Check the prining messages
        @print_test_conf.each do |method,conf|
            it "should put a #{method} message" do
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

		# Check the really_continue? function
        [ '', 'Yes', 'y', 'Y', 'yes' ].each do |answer|
            it "should really continue after answer '#{answer}'" do
                STDIN.should_receive(:gets).and_return(answer)
                results = capture(:stdout) { really_continue? }
                results.should =~ /=> Do you really want to continue/;
                results.should =~ /Default: Yes/
            end
            next if answer.empty?
            it "should really continue (despite default answer 'No') after answer '#{answer}'" do
                STDIN.should_receive(:gets).and_return(answer)
                results = capture(:stdout) { really_continue?('No') }
                results.should =~ /=> Do you really want to continue/;
                results.should =~ /Default: No/
            end
        end

        [ '', 'No', 'n', 'N', 'no' ].each do |answer|
            it "should not continue (despite default answer 'No') and exit after answer '#{answer}'" do
                STDIN.should_receive(:gets).and_return(answer)
                results = capture(:stdout) {
                    lambda{
                        really_continue?('No')
                    }.should raise_error (SystemExit)
                }
                results.should =~ /=> Do you really want to continue/;
                results.should =~ /Default: No/
            end
            next if answer.empty?
            it "should not continue and exit after answer '#{answer}'" do
                STDIN.should_receive(:gets).and_return(answer)
                results = capture(:stdout) {
                    lambda{
                        really_continue?
                    }.should raise_error (SystemExit)
                }
                results.should =~ /=> Do you really want to continue/;
                results.should =~ /Default: Yes/
            end
        end



    end

end
