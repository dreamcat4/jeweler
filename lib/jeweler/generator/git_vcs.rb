class Jeweler
  class Generator
    class GitVcs < Plugin
      def run
        git_init destination_root
        add_git_remote destination_root, 'origin', git_remote
      end
    end
  end
end
