#!/usr/bin/env sh

bundle exec rake test

#BEAKER_set=ubuntu-server-12042-x64 BEAKER_debug=yes bundle exec rspec spec/acceptance
BEAKER_destroy=no BEAKER_set=centos-64-x64 BEAKER_debug=yes bundle exec rspec spec/acceptance

#for i in `ls -l spec/acceptance/nodesets/ | awk '{if (NR>1)print $9}' | sed -e 's/\.yml//g'`
#do
#  BEAKER_set=$i BEAKER_debug=yes bundle exec rspec spec/acceptance
#done