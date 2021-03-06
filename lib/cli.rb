require 'thor'

class Exercism
  class CLI < Thor

    desc "fetch", "Fetch current assignment from exercism.io"
    method_option :host, aliases: '-h', default: 'http://exercism.io', desc: 'the url of the exercism application'
    def fetch
      require 'exercism'

      api = Exercism::Api.new(options[:host], Exercism.user, Exercism.project_dir)
      assignments = api.fetch
      if assignments.empty?
        puts "No assignments fetched."
      else
        assignments.each do |assignment|
          puts "Fetched #{File.join(assignment.assignment_dir)}"
        end
      end
    end

    desc "submit FILE", "Submit code to exercism.io on your current assignment"
    method_option :host, aliases: '-h', default: 'http://exercism.io', desc: 'the url of the exercism application'
    def submit(file)
      require 'exercism'

      path = File.join(FileUtils.pwd, file)
      Exercism::Api.new(options[:host], Exercism.user).submit(file)
    end

    desc "login", "Save exercism.io api credentials"
    def login
      require 'exercism'

      username = ask("Your GitHub username:")
      key = ask("Your exercism.io API key:")
      default_path = FileUtils.pwd
      path = ask("What is your exercism exercises project path? (#{default_path})")
      if path.empty?
        path = default_path
      end
      path = File.expand_path(path)
      Exercism.login(username, key, path)

      say("Your credentials have been written to #{Exercism.config.file}")
    end

    desc "logout", "Clear exercism.io api credentials"
    def logout
      require 'exercism'

      Exercism.config.delete
    end

    desc "whoami", "Get the github username that you are logged in as"
    def whoami
      require 'exercism'

      puts Exercism.user.github_username
    rescue Errno::ENOENT
      puts "You are not logged in."
    end

  end
end
