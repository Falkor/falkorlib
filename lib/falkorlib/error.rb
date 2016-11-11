# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Fri 2016-11-11 14:25 svarrette>
################################################################################
# Falkorlib errors

module FalkorLib

  # Errors
  class Error < ::StandardError

    class << self

      attr_accessor :status_code

    end

    def status_code
      self.class.status_code
    end

  end

  # default Exit
  class Exit             < Error; self.status_code = 0; end
  # regular error
  class FalkorError      < Error; self.status_code = 1; end
  # execution error
  class ExecError        < Error; self.status_code = 2; end
  # internal management error
  class InternalError    < Error; self.status_code = 3; end
  # argument error
  class ArgumentError    < Error; self.status_code = 4; end
  # abording
  class AbortError       < Error; self.status_code = 5; end
  # template not found
  class TemplateNotFound < Error; self.status_code = 6; end

end
