#! /bin/bash

# these are reduced definitions for utility operators taken from the dydra http api tests
# (https://github.com/dydra/http-api-tests)
# it is intended to be sourced
#
# environment :
# STORE_HOST : http host name
# STORE_ACCOUNT : account name                 : default "openrdf-sesame"
# STORE_REPOSITORY : individual repository     : default "mem-rdf"
# STORE_TOKEN : the authentication token
#
# this defines several operators for RDF|SPARQL access to the given store
#
# curl_sparql_request
#   curl_sparql_query
#   curl_sparql_update
#   curl_sparql_view
# graph_store_get
# graph_store_update
#
#

if [[ "" == "${STORE_TOKEN}" ]]
then
    echo "STORE_TOKEN is required"
    return 1
fi


if [[ "" == "${STORE_HOST}" ]]
then
  export STORE_HOST="dydra.com:8443"
fi
if [[ "" == "${STORE_ACCOUNT}" ]]
then
  export STORE_ACCOUNT="seg"
fi
if [[ "" == "${STORE_REPOSITORY}" ]]
then
  export STORE_REPOSITORY="test";
fi
export STORE_URL=https://${STORE_HOST}
export STORE_GRAPH_MEDIA_TYPE="application/n-quads"
export STORE_ACCEPT="Accept: application/sparql-results+json"
export STORE_ACCEPT_GRAPH="Accept: application/n-triples"
export STORE_SPARQL_QUERY_MEDIA_TYPE="application/sparql-query"
export STORE_SPARQL_UPDATE_MEDIA_TYPE="application/sparql-update"
export STORE_SPARQL_RESULTS_MEDIA_TYPE="application/sparql-results+json"

export STATUS_OK=200
export STATUS_ACCEPTED='202'
export STATUS_DELETE_SUCCESS='200|204'
export STATUS_PATCH_SUCCESS='200|201|204'
export POST_SUCCESS='200|201|204'
export STATUS_POST_SUCCESS='200|201|204'
export PUT_SUCCESS='201|204'
export STATUS_PUT_SUCCESS='200|201|204'
export STATUS_CREATED=201
export STATUS_NO_CONTENT=204
export STATUS_UPDATED='201|204'
export DELETE_SUCCESS=204
export STATUS_BAD_REQUEST=400
export STATUS_UNAUTHORIZED=401
export STATUS_NOT_FOUND=404
export STATUS_NOT_ACCEPTABLE=406
export STATUS_UNSUPPORTED_MEDIA=415
export STATUS_NOT_IMPLEMENTED=501

if [[ "" == "${CURL}" ]]
then
  export CURL="curl --ipv4 --http1.1 -k"  # ignore certificates
fi
# export CURL="curl -v --ipv4"
# export CURL="curl --ipv4 --trace-ascii /dev/tty"
if [[ "" == "${ECHO_OUTPUT}" ]]
then
  export ECHO_OUTPUT=/dev/null # /dev/tty # 
fi

export RESULT_OUTPUT="/tmp/$$.out"
export QUERY_INPUT="/tmp/$$.rq"


function 1cpl () {
 sed 's/[[:space:]]*//g' | sed 's/\(.\)/\1\
/g'
}
export -f 1cpl

if ! [ -x "$(command -v md5sum)" ]; then
  function md5sum () {
    md5
  }
  export -f md5sum
fi

# indicate whether those put/post operations for which the request specified the default graph, will apply any
# quad statements to the default graph or to that graph from the statement. false implies by statement.
export QUAD_DISPOSITION_BY_REQUEST=false
STORE_ERRORS=0

function test_bad_request () {
  egrep -q "${STATUS_BAD_REQUEST}"
}

function test_accepted () {
  egrep -q "${STATUS_ACCEPTED}"
}

function test_delete_success () {
  egrep -q "${STATUS_DELETE_SUCCESS}"
}

function test_not_acceptable () {
  egrep -q "${STATUS_NOT_ACCEPTABLE}"
}
function test_not_acceptable_success () {
  egrep -q "${STATUS_NOT_ACCEPTABLE}"
}

function test_unauthorized () {
  egrep -q "${STATUS_UNAUTHORIZED}"
}
function test_unauthorized_success () {
  egrep -q "${STATUS_UNAUTHORIZED}"
}

function test_not_found () {
  egrep -q "${STATUS_NOT_FOUND}|${STATUS_BAD_REQUEST}"
}
function test_not_found_success () {
  egrep -q "${STATUS_NOT_FOUND}"
}

function test_not_implemented () {
  egrep -q "${STATUS_NOT_IMPLEMENTED}"
}

function test_ok () {
  egrep -q "${STATUS_OK}|${STATUS_NO_CONTENT}"
}
function test_success () {
  egrep -q "${STATUS_OK}|${STATUS_NO_CONTENT}"
}
function test_ok_success () {
  egrep -q "${STATUS_OK}"
}

function test_patch_success () {
  egrep -q "${STATUS_PATCH_SUCCESS}"
}

function test_post_success () {
  egrep -q "${STATUS_POST_SUCCESS}"
}

function test_put_success () {
  egrep -q "${STATUS_PUT_SUCCESS}"
}

function test_unsupported_media () {
  egrep -q "${STATUS_UNSUPPORTED_MEDIA}"
}

function test_updated () {
  egrep -q "${STATUS_UPDATED}"
}


# curl_sparql_request { $accept-header-argument } { $content-type-header-argument } { $url }
function curl_sparql_request () {
  local -a curl_args=()
  local -a accept_media_type=("-H" "Accept: $STORE_SPARQL_RESULTS_MEDIA_TYPE")
  local -a content_media_type=("-H" "Content-Type: $STORE_SPARQL_QUERY_MEDIA_TYPE")
  local -a method=("-X" "POST")
  local -a data=()
  local -a user=(-u ":${STORE_TOKEN}")
  local -a user_id=("user_id=$0")
  local -a curl_url="${SPARQL_URL}"
  local -a url_args=()
  local -a account=${STORE_ACCOUNT}
  local -a repository=${STORE_REPOSITORY}

  while [[ "$#" > 0 ]] ; do
    # echo "arg $1";
    case "$1" in
      -H) case "$2" in
          Accept:*) accept_media_type[1]="${2}"; shift 2;;
          Content-Type:*) content_media_type[1]="${2}"; shift 2;;
          *) curl_args+=("${1}" "${2}"); shift 2;;
          esac ;;
      --account) account="${2}"; shift 2;;
      --repository) repository="${2}"; shift 2;;
      -u|--user) if [[ -z "${2}" ]]; then user=(); else user[1]="${2}"; fi; shift 2;;
      -X) method[1]="${2}"; shift 2;;
      --data*) data+=("${1}" "${2}"); shift 2;;
      --head) method=(); curl_args+=("${1}"); shift 1;;
      query=*) data=(); content_media_type=(); url_args+=("${1}"); method=("-X" "GET"); shift 1;;
      user_id=*) user_id=("${1}"); shift 1;;
      *=*) url_args+=("${1}"); shift 1;;
      *) curl_args+=("${1}"); shift 1;;
    esac
    # echo "curl_args in loop ${curl_args[@]}" > /dev/tty
  done
  # echo "curl_args ${curl_args[@]}" > /dev/tty
  curl_url="${STORE_URL}/${account}/${repository}/sparql"
  url_args+=(${user_id[@]})
  if [[ ${#url_args[*]} > 0 ]] ; then curl_url=$(IFS='&' ; echo "${curl_url}?${url_args[*]}") ; fi
  if [[ ${#data[*]} == 0 && ${method[1]} == "POST" ]] ; then data=("--data-binary" "@-"); fi
  # where an empty array is possible, must be conditional due to unset variable constraint
  if [[ ${accept_media_type[1]} != "Accept:" ]]; then curl_args+=("${accept_media_type[@]}"); fi
  if [[ ${#content_media_type[*]} > 0 ]] ; then curl_args+=("${content_media_type[@]}"); fi
  if [[ ${#data[*]} > 0 ]] ; then curl_args+=("${data[@]}"); fi
  if [[ ${#method[*]} > 0 ]] ; then curl_args+=(${method[@]}); fi
  if [[ ${#user[*]} > 0 ]] ; then curl_args+=(${user[@]}); fi

  echo ${CURL} -L -f -s "${curl_args[@]}" ${curl_url} > $ECHO_OUTPUT
  mkdir -p /tmp/test/
  ${CURL} -L -f -s "${curl_args[@]}" ${curl_url}
}


function curl_sparql_query () {
  curl_sparql_request -H "Content-Type:application/sparql-query" "$@"
}

function curl_sparql_update () {
  curl_sparql_request -H "Content-Type:application/sparql-update" "$@"
}


# curl_sparql_view { accept-header-argument } { content-type-header-argument } { view_name }
# operate with/on a view
function curl_sparql_view () {
  local -a curl_args=()
  local -a accept_media_type=("-H" "Accept: $STORE_SPARQL_RESULTS_MEDIA_TYPE")
  local -a content_media_type=("-H" "Content-Type: $STORE_SPARQL_QUERY_MEDIA_TYPE")
  local -a method=("-X" "GET")
  local -a data=()
  local -a user=(-u ":${STORE_TOKEN}")
  local -a user_id=("user_id=$0")
  local graph=""  #  the default is all graphs
  local curl_url=""
  local url_args=()
  local account=${STORE_ACCOUNT}
  local repository=${STORE_REPOSITORY}
  local view="sparql" # start out as the default service location

  while [[ "$#" > 0 ]] ; do
    case "$1" in
      --account) account="${2}"; shift 2;;
      default|DEFAULT) graph="default"; shift 1;;
      --graph) if [[ "" == "${2}" ]] ; then graph=""; else graph="graph=${2}"; fi;  shift 2;;
      -H) case "$2" in
          Accept:*) accept_media_type[1]="${2}"; shift 2;;
          Content-Type:*) content_media_type=("-H" "${2}"); shift 2;;
          *) curl_args+=("${1}" "${2}"); shift 2;;
          esac ;;
      -u|--user) if [[ -z "${2}" ]]; then user=(); else user[1]="${2}"; fi; shift 2;;
      -v) curl_args+=("-v"); shift 1;;
      -w) curl_args+=("${1}" "${2}"); shift 2;;
      -X) method[1]="${2}"; shift 2;;
      --data*) data+=("${1}" "${2}"); shift 2;;
      --head) method=(); curl_args+=("${1}"); shift 1;;
      query=*) data=(); content_media_type=(); url_args+=("${1}"); shift 1;;
      --repository) repository="${2}"; shift 2;;
      user_id=*) user_id=("${1}"); shift 1;;
      *=*) url_args+=("${1}"); shift 1;;
      *) view="${1}"; shift 1;;
    esac
  done
  curl_url="${STORE_URL}/${account}/${repository}/${view}"
  url_args+=(${user_id[@]})
  if [[ "${graph}" ]] ; then url_args+=(${graph[@]}); fi
  if [[ ${#url_args[*]} > 0 ]] ; then curl_url=$(IFS='&' ; echo "${curl_url}?${url_args[*]}") ; fi
  if [[ ${#data[*]} == 0 && ${method[1]} == "POST" ]] ; then data=("--data-binary" "@-"); fi
  # where an empty array is possible, must be conditional due to unset variable constraint
  curl_args+=("${accept_media_type[@]}");
  if [[ ${#content_media_type[*]} > 0 ]] ; then curl_args+=("${content_media_type[@]}"); fi
  if [[ ${#data[*]} > 0 ]] ; then curl_args+=("${data[@]}"); fi
  if [[ ${#method[*]} > 0 ]] ; then curl_args+=(${method[@]}); fi
  if [[ ${#user[*]} > 0 ]] ; then curl_args+=(${user[@]}); fi

  echo ${CURL} -L -f -s "${curl_args[@]}" ${curl_url} > $ECHO_OUTPUT
  ${CURL} -L -f -s "${curl_args[@]}" ${curl_url}
}


# curl_graph_store_delete { -H $accept-header-argument } { graph }
function curl_graph_store_delete () {
  curl_graph_store_get -X DELETE "$@"
}

# curl_graph_store_get { -H $accept-header-argument } {--repository $repository} { graph }
function curl_graph_store_get_nofail () {
  local -a curl_args=()
  local -a accept_media_type=("-H" "Accept: $STORE_GRAPH_MEDIA_TYPE")
  local -a content_media_type=()
  local -a method=("-X" "GET")
  local -a user=(-u ":${STORE_TOKEN}")
  local -a user_id=("user_id=$0")
  local graph=""  #  the default is all graphs
  local account=${STORE_ACCOUNT}
  local repository=${STORE_REPOSITORY}
  local curl_url=""
  local url_args=()
  curl_url="${STORE_URL}/${account}/${repository}/service"
  while [[ "$#" > 0 ]] ; do
    case "$1" in
      --account) account="${2}"; shift 2; curl_url="${STORE_URL}/${account}/${repository}/service";;
      all|ALL) graph="all"; shift 1;;
      default|DEFAULT) graph="default"; shift 1;;
      graph=*) graph="${1}"; shift 1;;
      --graph=*) graph="${1}"; shift 1;;
      -H) case "$2" in
          Accept:*) accept_media_type[1]="${2}"; shift 2;;
          Content-Type:*) content_media_type=("-H" "${2}"); shift 2;;
          *) curl_args+=("${1}" "${2}"); shift 2;;
          esac ;;
      --head) method=(); curl_args+=("${1}"); shift 1;;
      --repository) repository="${2}"; shift 2; curl_url="${STORE_URL}/${account}/${repository}/service";;
      --url) curl_url="${2}"; shift 2;;
      -u|--user) if [[ -z "${2}" ]]; then user=(); else user[1]="${2}"; fi; shift 2;;
      user_id=*) user_id=("${1}"); shift 1;;
      -X) method[1]="${2}"; shift 2;;
      *=*) url_args+=("${1}"); shift 1;;
      *) curl_args+=("${1}"); shift 1;;
    esac
  done
  url_args+=(${user_id[@]})
  if [[ "${graph}" ]] ; then url_args+=(${graph}); fi
  if [[ ${#url_args[*]} > 0 ]] ; then curl_url=$(IFS='&' ; echo "${curl_url}?${url_args[*]}") ; fi
  # where an empty array is possible, must be conditional due to unset variable constraint
  curl_args+=("${accept_media_type[@]}");
  if [[ ${#content_media_type[*]} > 0 ]] ; then curl_args+=(${content_media_type[@]}); fi
  if [[ ${#method[*]} > 0 ]] ; then curl_args+=(${method[@]}); fi
  if [[ ${#user[*]} > 0 ]] ; then curl_args+=(${user[@]}); fi

  echo ${CURL} -s "${curl_args[@]}" ${curl_url} > $ECHO_OUTPUT
  ${CURL} -s "${curl_args[@]}" ${curl_url}
}

function curl_graph_store_get () {
  curl_graph_store_get_nofail -f "$@"
}

# curl_graph_store_get_code { $accept-header-argument } { graph }
function curl_graph_store_get_code () {
  curl_graph_store_get -w "%{http_code}\n" "$@"
}

function curl_graph_store_get_code_nofail () {
  curl_graph_store_get_nofail -w "%{stderr}%{http_code}\n" "$@"
}

function curl_graph_store_update () {
  local -a curl_args=()
  local -a accept_media_type=()
  local -a content_encoding=()
  local -a content_media_type=("-H" "Content-Type: $STORE_GRAPH_MEDIA_TYPE")
  local -a data=("--data-binary" "@-")
  local -a method=("-X" "POST")
  local -a user=(-u ":${STORE_TOKEN}")
  local -a user_id=("user_id=$0")
  local -a output="/dev/stdout"
  local graph=""  #  the default is all graphs
  local account=${STORE_ACCOUNT}
  local repository=${STORE_REPOSITORY}
  local curl_url="${GRAPH_STORE_URL}"
  local url_args=()
  curl_url="${STORE_URL}/${account}/${repository}/service"
  while [[ "$#" > 0 ]] ; do
    case "$1" in
      --account) account="${2}"; shift 2; curl_url="${STORE_URL}/${account}/${repository}/service";;
      all|ALL) graph="all"; shift 1;;
      --data*) data[0]="${1}";  data[1]="${2}"; shift 2;;
      default|DEFAULT) graph="default"; shift 1;;
      graph=*) if [[ "graph=" == "${1}" ]] ; then graph=""; else graph="${1}"; fi;  shift 1;;
      --graph=*) if [[ "--graph=" == "${1}" ]] ; then graph=""; else graph="${1}"; fi;  shift 1;;
      -H) case "$2" in
          Accept:*) accept_media_type=("-H" "${2}"); shift 2;;
          Content-Type:*) content_media_type[1]="${2}"; shift 2;;
          Content-Encoding:*) content_encoding=("-H" "${2}"); shift 2;;
          *) curl_args+=("${1}" "${2}"); shift 2;;
          esac ;;
      -o) curl_args+=("-o" "${2}"); output="${2}"; shift 2;;
      --repository) repository="${2}";
        shift 2; curl_url="${STORE_URL}/${account}/${repository}/service";;
      --url) curl_url="${2}"; shift 2;;
      -u|--user) if [[ -z "${2}" ]]; then user=(); else user[1]="${2}"; fi; shift 2;;
      user_id=*) user_id=("${1}"); shift 1;;
      -X) method[1]="${2}"; shift 2;;
      -v) curl_args+=("-v"); shift 1;;
      -w) curl_args+=("${1}" "${2}"); output="/dev/stdout"; shift 2;;
      *) curl_args+=("${1}"); shift 1;;
    esac
  done
  url_args+=(${user_id[@]})
  if [[ "${graph}" ]] ; then url_args+=(${graph}); fi
  if [[ ${#url_args[*]} > 0 ]] ; then curl_url=$(IFS='&' ; echo "${curl_url}?${url_args[*]}") ; fi
  if [[ ${#accept_media_type[*]} > 0 ]] ; then curl_args+=("${accept_media_type[@]}"); fi
  if [[ ${#content_encoding[*]} > 0 ]] ; then curl_args+=("${content_encoding[@]}"); fi
  if [[ ${#content_media_type[*]} > 0 ]] ; then curl_args+=("${content_media_type[@]}"); fi
  if [[ ${#data[*]} > 0 ]] ; then curl_args+=("${data[@]}"); fi
  if [[ ${#method[*]} > 0 ]] ; then curl_args+=(${method[@]}); fi
  if [[ ${#user[*]} > 0 ]] ; then curl_args+=("${user[@]}"); fi

  echo  ${CURL} -f -s "${curl_args[@]}" ${curl_url} > $ECHO_OUTPUT
  ${CURL}  -f -s "${curl_args[@]}" ${curl_url} # > $output
}


function curl_graph_store_clear () {
  curl_graph_store_update -X DELETE "$@" -o /dev/null <<EOF
EOF
}

function curl_clear_repository_content () {
  curl_graph_store_update -X PUT "$@" -o /dev/null <<EOF
EOF
}


export -f curl_clear_repository_content
export -f curl_sparql_request
export -f curl_sparql_update
export -f curl_sparql_query
export -f curl_sparql_view
export -f curl_graph_store_clear
export -f curl_graph_store_delete
export -f curl_graph_store_get
export -f curl_graph_store_get_nofail
export -f curl_graph_store_get_code
export -f curl_graph_store_get_code_nofail
export -f curl_graph_store_update
export -f test_accepted
export -f test_bad_request
export -f test_delete_success
export -f test_not_found
export -f test_not_found_success
export -f test_not_acceptable
export -f test_not_acceptable_success
export -f test_not_implemented
export -f test_ok_success
export -f test_ok
export -f test_patch_success
export -f test_post_success
export -f test_put_success
export -f test_success
export -f test_unauthorized
export -f test_unauthorized_success
export -f test_unsupported_media
export -f test_updated

function run_test() {
  (cd `dirname "$1"`; bash -e "`basename \"$1\"`")
  if [[ "0" == "$?" ]]
  then
    echo "$1" succeeded
  else
    echo "$1" failed
  fi
}


