require "capistrano/git"
require "capistrano/hg"

module WFVIW
  module Capistrano
    module Strategy
      module Git
        include ::Capistrano::Git::DefaultStrategy

        def release_version
          context.capture(:git, "describe --abbrev=0 --tags")
        end
      end

      module Hg
        include ::Capistrano::Hg::DefaultStrategy

        def release_version
          context.capture(:hg, "parents --template '{latesttag}\n'")
        end
      end
    end
  end
end
