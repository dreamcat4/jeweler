class Jeweler
  module Commands
    module Ghpages
      class RemoveFromGhpages < Base

        def run
          super
          grancher = Grancher.new
          ghpages_url = setup_grancher_return_ghpages_url(grancher)
          grancher.message = "Removing #{gh_repo}'s gh-pages from #{ghpages_url}"

          output.puts "Removing #{gh_repo}'s gh-pages from #{ghpages_url}"
          grancher.commit
          grancher.push
        end

      end
    end
  end
end
