#!/bin/bash

set -ex

ROOT=$(pwd)
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
OUTPUT=${ROOT}/${FULLNAME}.tar.xz
S3OUTPUT=""
if echo "$2" | grep s3://; then
    S3OUTPUT=$2
else
    if [[ -d "${2}" ]]; then
        OUTPUT=$2/${FULLNAME}.tar.xz
    else
        OUTPUT=${2-$OUTPUT}
    fi
fi

CARBON_REVISION=$(git ls-remote --heads ${URL} "refs/heads/${BRANCH}" | cut -f 1)
REVISION="carbon-${CARBON_REVISION}"
LAST_REVISION="${3}"

PKGVERSION="Compiler-Explorer-Build-${REVISION}"

echo "ce-build-revision:${REVISION}"
echo "ce-build-output:${OUTPUT}"

if [[ "${REVISION}" == "${LAST_REVISION}" ]]; then
    echo "ce-build-status:SKIPPED"
    exit
fi

STAGING_DIR=$(pwd)/staging

git clone -q --depth 1 --single-branch -b "${BRANCH}" "${URL}" "carbon-${VERSION}"

pushd "carbon-${VERSION}"
bazel build -c opt //explorer/...
bazel run -c opt //installers/local:install "--//installers/local:install_path=${STAGING_DIR}"
popd

export XZ_DEFAULTS="-T 0"
tar Jcf "${OUTPUT}" --transform "s,^./,./carbon-${VERSION}/," -C "${STAGING_DIR}" .

if [[ -n "${S3OUTPUT}" ]]; then
    aws s3 cp --storage-class REDUCED_REDUNDANCY "${OUTPUT}" "${S3OUTPUT}"
fi

echo "ce-build-status:OK"
