#!/bin/bash

set -x

IP=$(ip route show |grep -o src.* |cut -f2 -d" ")
# kubernetes sets routes differently -- so we will discover our IP differently
if [[ ${IP} == "" ]]; then
  IP=$(hostname -i)
fi

az=$(curl -s ${ECS_CONTAINER_METADATA_URI_V4}/task | jq -r .AvailabilityZone)

zone="${az: -1}"

case "${zone}" in
  a)
    color=Crimson
    ;;
  b)
    color=CornflowerBlue
    ;;
  c) 
    color=LightGreen
    ;;
  d)
    color=Yellow
    ;;
  *)
    color=White
    ;;
esac

export CODE_HASH="$(cat code_hash.txt)"
export IP
export AZ="${IP} in AZ-${zone}"

# exec bundle exec thin start
RAILS_ENV=production rake assets:precompile
exec rails s -e production -b 0.0.0.0
