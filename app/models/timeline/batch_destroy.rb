module Timeline

  class BatchDestroy < BatchOp
    def batch_operation(user, step)
      Pundit.authorize user, step, :batch_destroy?
      step.destroy
    end
  end

end
