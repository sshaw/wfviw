require "capistrano/git"
require "capistrano/hg"

module WFVIW
  module Capistrano
    module Strategy
      module Git
        include ::Capistrano::Git::DefaultStrategy

        def release_version
          context.capture(:git, "describe --abbrev=0 --tags").strip
        end
      end

      module Hg
        include ::Capistrano::Hg::DefaultStrategy

        def release_version
          context.capture(:hg, "parents --template '{latesttag}'")
        end
      end

      module Svn
        include ::Capistrano::Git::DefaultStrategy

        def release_version
          log = context.capture(:svn, "-v log --limit 1 ^/tags").strip
          return $1 if log =~ %r|\s/tags/([^\s]+)|
        end
      end
    end
  end
end
