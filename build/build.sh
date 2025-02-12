#!/bin/bash

set -ex

VERSION=$1
if echo "${VERSION}" | grep 'trunk'; then
    VERSION=trunk-$(date +%Y%m%d)
    URL=https://github.com/carbon-language/carbon-lang.git
    BRANCH=trunk
else
    echo "Not yet supported"
    exit 1
fi

FULLNAME=carbon-${VERSION}
OUTPUT=$2/${FULLNAME}.tar.xz

REVISION="carbon-${VERSION}"
LAST_REVISION="${3}"

echo "ce-build-revision:${REVISION}"
echo "ce-build-output:${OUTPUT}"

if [[ "${REVISION}" == "${LAST_REVISION}" ]]; then
   echo "ce-build-status:SKIPPED"
   exit
fi

STAGING_DIR=$(pwd)/staging
BUILD_DIR=$(pwd)/build
rm -rf ${STAGING_DIR} ${BUILD_DIR}

mkdir -p ${BUILD_DIR}
pushd ${BUILD_DIR}
git clone -q --depth 1 --single-branch -b "${BRANCH}" "${URL}" "carbon-${VERSION}"

pushd "carbon-${VERSION}"
bazel build -c opt //explorer/...
bazel run -c opt //installers/local:install "--//installers/local:install_path=${STAGING_DIR}"
popd

export XZ_DEFAULTS="-T 0"
tar Jcf "${OUTPUT}" --transform "s,^./,./carbon-${VERSION}/," -C "${STAGING_DIR}" .

echo "ce-build-status:OK"
