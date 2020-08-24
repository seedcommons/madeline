# Department in QB = Division in Madeline
#
# Helpers Madeline divisions with QB Departments

module Accounting
  module QB
    class DepartmentHelper
      # The gem does not implement a helper method for _id like account or class.
      def reference(division)
        qb_department_id = division.qb_department.try(:qb_id)
        return if qb_department_id.blank?
        ::Quickbooks::Model::BaseReference.new(qb_department_id)
      end
    end
  end
end
