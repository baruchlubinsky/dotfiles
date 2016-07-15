#! /bin/bash

tree() {
    dir=${1:-.}
    ls -R ${dir}| grep ":$" | sed -e 's/:$//' -e 's/[^-][^\/]*\//--/g' -e 's/^/   /' -e 's/-/|/'
}

