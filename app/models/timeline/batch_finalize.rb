module Timeline

  class BatchFinalize < BatchOp

    protected

    def batch_operation(user, step)
      step.finalize
    end

    def authorization_key
      :finalize?
    end
  end

end
