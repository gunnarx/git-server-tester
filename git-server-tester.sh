#!/bin/bash
# (C) 2016 Gunnar Andersson
# LICENSE: MPLv2

REPOLIST_BASE=http://git.projects.genivi.org
FETCH_URL=git://git.projects.genivi.org
WAIT=30
PICK=3

# Aaargh, need to remove repos that are empty...
blacklist="canfw.git|franca-mdg.git|genivi-ocf-demo.git|ipc/af_bus-glib.git|persistence/persistence-configuration-tool.git|popupmanager.git|rvi_core.git|user-management/user-data-migration-service.git"

echo Getting repository list...
REPOLIST="$(curl -s $REPOLIST_BASE | fgrep 'class="list" href="' | sed 's/.*p=\(.*.git\);.*/\1/' | egrep -v \"$blacklist\")"
LENGTH=$(echo "$REPOLIST" | wc -l)

echo
echo $REPOLIST
echo $LENGTH repositories.
echo


rand() {
   echo $(( RANDOM %= $1 ))
}

# Pick n random items from list
pick() {
  n=$1
  shift

  c=0
  while [ $c -lt $n ] ; do
    r=$(rand $LENGTH)  # Random nbr between 0 and LENGTH-1
    r=$(($r+1))        # between 1 and LENGTH

    echo "$*" | sed -n "${r}p"        # Print that line
    c=$(($c+1))        # Loop count
  done
}


while true ; do

  repos=$(pick $PICK "$REPOLIST")
  echo -n "$(date): Trying $PICK random repos. "
  for repo in $repos ; do
    url="$FETCH_URL/$repo"
     git ls-remote $url HEAD >/dev/null
     if [ $? -eq 0 ] ; then 
        echo -n ok,
     else
       echo
       echo "$(date) FAILED FETCHING $url"
       exit 1
     fi
   done

   echo " Waiting $WAIT seconds."
   sleep $WAIT

done

sleep $WAIT
