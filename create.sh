#!/bin/sh

set -euo pipefail

modulename="$1"
mydir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
basedir="$mydir/.."


##
echo "[[ Creating repository for $modulename ]]"
echo
##

gitlab_token=$(cat $mydir/gitlab_token)
gitlab_url="http://gitlab.tre.esav.fi"
gitlab_namespace_id="4"

response=$(curl --header "PRIVATE-TOKEN: $gitlab_token" -X POST "$gitlab_url/api/v3/projects?name=$modulename&namespace_id=$gitlab_namespace_id" 2>/dev/null)
echo $response
echo

echo "Created repository $( echo "$response" | jq '.web_url' )"
echo


##
echo "[[ Cloning repository ]]"
echo
##

cd $basedir
git clone $( echo "$response" | jq '.ssh_url_to_repo' | tr -d '"')


##
echo "[[ Making initial commit ]]"
echo
##

cd $modulename
mkdir manifests

cat > manifests/init.pp <<EOS
class $modulename {

}
EOS

git add manifests/init.pp
git commit -m 'Initial commit (created by puppet-module-creator)'
git push origin master


echo "[[ Done ]]"
echo 

echo "Add this to the Puppetfile:"
echo "###################################################################################"
echo 
echo "mod '$modulename',"
echo "    :git    => 'git@gitlab.tre.esav.fi:puppet/$modulename.git',"
echo "    :branch => 'master'"
echo
echo "###################################################################################"
echo

