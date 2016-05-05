# Globally disable the root element when rendering json
# Beware, this 'root = false' doesn't seem to have an effect.
# JE Todo: Understand why.
ActiveModel::Serializer.root = false