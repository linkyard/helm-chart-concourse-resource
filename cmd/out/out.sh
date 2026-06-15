#!/bin/bash

set -e 

exec 3>&1 # make stdout available as fd 3 for the result
exec 1>&2 # redirect all output to stderr for logging

baseDir=$1

request=$(cat)
sourceDir=$1

cd ${sourceDir}

repository_url=$(echo ${request} | jq -r '.source.repository_url // ""')
chart=$(echo ${request} | jq -r '.source.chart // ""')
username=$(echo ${request} | jq -r '.source.username // ""')
password=$(echo ${request} | jq -r '.source.password // ""')
skip_tls_validation=$(echo ${request} | jq -r '.source.skip_tls_validation // ""')

repository=$(echo ${request} | jq -r '.params.repository // "."')
version_file=$(echo ${request} | jq -r  '.params.version_file // ""')
push_type=$(echo ${request} | jq -r '.source.push_type // "nexus-push"')

# Resolve glob to actual chart file
chart_file=$(ls ${repository} 2>/dev/null | head -1)
[[ -z "${chart_file}" ]] && chart_file="${repository}"

if [[ "${push_type}" == "cm-push" ]]; then
  HELM_REPO_USERNAME="${username}" HELM_REPO_PASSWORD="${password}" helm cm-push "${chart_file}" "${repository_url}"
else
  repo_name="put-${RANDOM}"
  helm repo add ${repo_name} ${repository_url} --username "${username}" --password "${password}"
  USERNAME="${username}" PASSWORD="${password}" helm nexus-push ${repo_name} "${chart_file}"
fi

[ -f "$(dirname ${repository})/metadata.json" ] && \
    metadata=$(cat "$(dirname ${repository})/metadata.json") || \
    metadata="[ {\"name\": \"repository\", \"value\": \"${repository_url}\"}, {\"name\": \"chart\", \"value\": \"${chart}\"} ]"

version=$(helm show chart "${chart_file}" | grep '^version:' | awk '{print $2}' | tr -d "'\"")

jq -n --arg version "${version}" --argjson metadata "${metadata}" '{"version": {"version": $version}, "metadata": $metadata }' >&3
