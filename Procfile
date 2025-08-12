web: bundle exec puma -p $PORT -C ./config/puma.rb
worker: bin/jobs
release: bundle exec rails db:migrate
