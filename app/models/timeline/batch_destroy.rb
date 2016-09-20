module Timeline

  class BatchDestroy < BatchOp
    def batch_operation(user, step)
      step.destroy
    end

    def authorization_key
      :batch_destroy?
    end
  end

end
