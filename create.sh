#!/bin/sh

set -euo pipefail

modulename="$1"
basedir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/.."


##
echo "Creating repository for $modulename"
##

gitlab_token=$(cat gitlab_token)
gitlab_url="http://gitlab.tre.esav.fi"
gitlab_namespace_id="4"

#response=$(curl --header "PRIVATE-TOKEN: $gitlab_token" -X POST "$gitlab_url/api/v3/projects?name=$modulename&namespace_id=$gitlab_namespace_id")
response='{"id":64,"description":null,"default_branch":null,"tag_list":[],"public":false,"archived":false,"visibility_level":0,"ssh_url_to_repo":"git@gitlab.esav.fi:puppet/esav_test2.git","http_url_to_repo":"https://gitlab.esav.fi/puppet/esav_test2.git","web_url":"https://gitlab.esav.fi/puppet/esav_test2","name":"esav_test2","name_with_namespace":"puppet / esav_test2","path":"esav_test2","path_with_namespace":"puppet/esav_test2","container_registry_enabled":true,"issues_enabled":true,"merge_requests_enabled":true,"wiki_enabled":true,"builds_enabled":true,"snippets_enabled":false,"created_at":"2017-12-13T03:42:44.315Z","last_activity_at":"2017-12-13T03:42:44.315Z","shared_runners_enabled":true,"lfs_enabled":true,"creator_id":7,"namespace":{"id":4,"name":"puppet","path":"puppet","kind":"group"},"avatar_url":null,"star_count":0,"forks_count":0,"open_issues_count":0,"runners_token":"Nh6n3T8RZF5CSGghedzD","public_builds":true,"shared_with_groups":[],"only_allow_merge_if_build_succeeds":false,"request_access_enabled":false,"only_allow_merge_if_all_discussions_are_resolved":false}'
#echo $response
echo "Created repository $( echo "$response" | jq '.web_url' )"


##
echo "Cloning repository"
##

cd $basedir
git clone $( echo "$response" | jq '.ssh_url_to_repo' | tr -d '"')
cd $modulename

mkdir manifests

cat > manifests/init.pp <<EOS
class $modulename {

}
EOS

git add manifests/init.pp
git commit -m 'Initial commit (created by puppet-module-creator)'
git push origin master

echo "Done."
echo ""

echo "Add this to the Puppetfile:"
echo "mod '$modulename',"
echo "    :git    => 'git@gitlab.tre.esav.fi:puppet/$modulename.git',"
echo "    :branch => 'master'"

