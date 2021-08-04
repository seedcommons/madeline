class ApplicationSerializer < ActiveModel::Serializer
  # ActiveModel Serializers seems to have a bug in which it tries to determine a root key
  # even though we are using the :attributes adapter, which doesn't use a root.
  # This shows up when one tries to `render(json: collection)` where collection is some collection of
  # objects that has a valid guessable serializer.
  # Setting type to empty string is a workaround for this.
  type ""
end
