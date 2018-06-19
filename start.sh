# checa e instala as gems se necessário
bundle check || bundle install
# inicializa o servidor
bundle exec puma -C config/puma.rb