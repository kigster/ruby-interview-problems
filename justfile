set shell := ["bash", "-c"]

set dotenv-load

test:
    @bundle check || bundle install -j 12 
    @bundle exec rake solutions:specs

# Setup Ruby dependencies
setup-ruby:
    #!/usr/bin/env bash
    [[ -d ~/.rbenv ]] || git clone https://github.com/rbenv/rbenv.git ~/.rbenv
    [[ -d ~/.rbenv/plugins/ruby-build ]] || git clone https://github.com/rbenv/rbenv.git ~/.rbenv
    cd ~/.rbenv/plugins/ruby-build && git pull && cd - >/dev/null
    echo -n "Checking if Ruby $(cat .ruby-version | tr -d '\n') is already installed..."
    rbenv install -s "$(cat .ruby-version | tr -d '\n')" >/dev/null 2>&1 && echo "yes" || echo "it wasn't, but now it is"
    bundle check || bundle install -j 12

setup: setup-ruby

format:
    @bundle exec rubocop -a
    @bundle exec rubocop --auto-gen-config

lint: 
    @bundle exec rubocop

