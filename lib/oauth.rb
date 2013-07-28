class Huboard
  module OAuth 
    def self.registered(app)
      app.use Sinatra::Auth::Github::AccessDenied
      app.use Sinatra::Auth::Github::BadAuthentication

      app.use Warden::Manager do |manager|
        manager.default_strategies :github

        manager.failure_app           = app.github_options[:failure_app] || Sinatra::Auth::Github::BadAuthentication

        puts app.github_options

        manager[:github_secret]       = app.github_options[:secret]       || ENV['GITHUB_CLIENT_SECRET']
        manager[:github_scopes]       = app.github_options[:scopes]       || ''
        manager[:github_client_id]    = app.github_options[:client_id]    || ENV['GITHUB_CLIENT_ID']
        manager[:github_callback_url] = app.github_options[:callback_url] || '/auth/github/callback'
      end

      app.helpers Sinatra::Auth::Github::Helpers

      app.get '/auth/github/callback' do
        if params["error"]
          redirect "/unauthenticated"
        else
          authenticate!
          return_to = session.delete('return_to') || _relative_url_for('/')
          redirect return_to
        end
      end
    end
  end
end
