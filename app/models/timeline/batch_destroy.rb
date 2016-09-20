module Timeline

  class BatchDestroy < BatchOp

    protected

    def batch_operation(user, step)
      step.destroy
    end

    def authorization_key
      :batch_destroy?
    end
  end

end
