# Maintains a list of application level caching, so that all caches can be cleared during test specs
# or when otherwise needed
# future: consider adding a 'category' param to  add_hook to allow invoking filtered subsets
#
# Note, for this approach to be fully useful, we'll need a clever way to clear the cache across all server processes.
# This could be handled through a timestamp stored into the shared Rails.cache to trigger
# clearing this cache on each instance.
#

# UNUSED:
# note, this code is currently unused, but anticipated to be useful.
# will be removed before release if not ultimately useful

class AdHocCacheManager

  # list of blocks to be executed when caches need clearing
  @@hooks = []


  def self.add_hook(name, &block)
    @@hooks << {name: name, block: block}
  end

  def self.clear_all
    Rails.logger.info("AdHocCacheManager - clear_all - hooks size: #{@@hooks.size}")
    @@hooks.each do |hook|
      Rails.logger.debug("hook: #{hook[:name]}")
      hook[:block].call
    end
  end


end