module Timeline

  class BatchFinalize < BatchOp
    def batch_operation(user, step)
      step.finalize
    end

    def authorization_key
      :finalize?
    end
  end

end
