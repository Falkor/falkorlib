require 'spec_helper'
require "falkorlib/error"


describe FalkorLib::Error do

    #############################################
    context "Test Falkorlib errors" do

        exceptions = [
                      FalkorLib::Exit,
                      FalkorLib::FalkorError,
                      FalkorLib::ExecError,
                      FalkorLib::InternalError,
                      FalkorLib::ArgumentError,
                      FalkorLib::AbortError,
                      FalkorLib::TemplateNotFound
                     ]
        exceptions.each do |e|
            it "##{e} -- exit code #{exceptions.index(e)}" do
                expect { raise e }.to raise_error
                begin
                    raise e
                rescue StandardError => s
                    i = s.status_code
                    expect(i).to eq(exceptions.index(e))
                end
            end
        end
    end


end
