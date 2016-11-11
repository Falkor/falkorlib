# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Fri 2016-11-11 14:21 svarrette>
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

  class Exit             < Error; self.status_code = 0; end
  class FalkorError      < Error; self.status_code = 1; end
  class ExecError        < Error; self.status_code = 2; end
  class InternalError    < Error; self.status_code = 3; end
  class ArgumentError    < Error; self.status_code = 4; end
  class AbortError       < Error; self.status_code = 5; end
  class TemplateNotFound < Error; self.status_code = 6; end
end
