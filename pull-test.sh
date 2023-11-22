#! /bin/sh

# Copyright 2021 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This script is called by pull Prow jobs for the csi-release-tools
# repo to ensure that the changes in the PR work when imported into
# some other repo.

set -ex

git version

# It must be called inside the updated csi-release-tools repo.
CSI_RELEASE_TOOLS_DIR="$(pwd)"

git status
git diff
git diff-index HEAD

# Update the other repo.
cd "$PULL_TEST_REPO_DIR"

git branch

# git reset --hard # Shouldn't be necessary, but somehow is to avoid "fatal: working tree has modifications.  Cannot add." (https://stackoverflow.com/questions/3623351/git-subtree-pull-says-that-the-working-tree-has-modifications-but-git-status-sa)
if ! git subtree pull -d --squash --prefix=release-tools "$CSI_RELEASE_TOOLS_DIR" master; then
    set +e
    git status
    git diff
    git diff-index HEAD
    git reset --hard
    git diff-index HEAD
    exit 1
fi
git log -n2

# Now fall through to testing.
exec ./.prow.sh
