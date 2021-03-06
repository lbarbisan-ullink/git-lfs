#!/usr/bin/env bash

. "test/testlib.sh"

envInitConfig='git config filter.lfs.smudge = "git-lfs smudge %f"
git config filter.lfs.clean = "git-lfs clean %f"'

begin_test "env with no remote"
(
  set -e
  reponame="env-no-remote"
  mkdir $reponame
  cd $reponame
  git init

  localwd=$(native_path "$TRASHDIR/$reponame")
  localgit=$(native_path "$TRASHDIR/$reponame/.git")
  localgitstore=$(native_path "$TRASHDIR/$reponame/.git")
  localmedia=$(native_path "$TRASHDIR/$reponame/.git/lfs/objects")
  tempdir=$(native_path "$TRASHDIR/$reponame/.git/lfs/tmp")
  envVars=$(printf "%s" "$(env | grep "^GIT")")

  expected=$(printf '%s
%s

LocalWorkingDir=%s
LocalGitDir=%s
LocalGitStorageDir=%s
LocalMediaDir=%s
TempDir=%s
ConcurrentTransfers=3
BatchTransfer=true
%s
%s
' "$(git lfs version)" "$(git version)" "$localwd" "$localgit" "$localgitstore" "$localmedia" "$tempdir" "$envVars" "$envInitConfig")
  actual=$(git lfs env)

  contains_same_elements "$expected" "$actual"
)
end_test

begin_test "env with origin remote"
(
  set -e
  reponame="env-origin-remote"
  mkdir $reponame
  cd $reponame
  git init
  git remote add origin "$GITSERVER/env-origin-remote"

  endpoint="$GITSERVER/$reponame.git/info/lfs (auth=none)"
  localwd=$(native_path "$TRASHDIR/$reponame")
  localgit=$(native_path "$TRASHDIR/$reponame/.git")
  localgitstore=$(native_path "$TRASHDIR/$reponame/.git")
  localmedia=$(native_path "$TRASHDIR/$reponame/.git/lfs/objects")
  tempdir=$(native_path "$TRASHDIR/$reponame/.git/lfs/tmp")
  envVars=$(printf "%s" "$(env | grep "^GIT")")
  expected=$(printf '%s
%s

Endpoint=%s
LocalWorkingDir=%s
LocalGitDir=%s
LocalGitStorageDir=%s
LocalMediaDir=%s
TempDir=%s
ConcurrentTransfers=3
BatchTransfer=true
%s
%s
' "$(git lfs version)" "$(git version)" "$endpoint" "$localwd" "$localgit" "$localgitstore" "$localmedia" "$tempdir" "$envVars" "$envInitConfig")
  actual=$(git lfs env)
  contains_same_elements "$expected" "$actual"

  cd .git
  expected2=$(echo "$expected" | sed -e 's/LocalWorkingDir=.*/LocalWorkingDir=/')
  actual2=$(git lfs env)
  contains_same_elements "$expected2" "$actual2"
)
end_test

begin_test "env with multiple remotes"
(
  set -e
  reponame="env-multiple-remotes"
  mkdir $reponame
  cd $reponame
  git init
  git remote add origin "$GITSERVER/env-origin-remote"
  git remote add other "$GITSERVER/env-other-remote"

  endpoint="$GITSERVER/env-origin-remote.git/info/lfs (auth=none)"
  endpoint2="$GITSERVER/env-other-remote.git/info/lfs (auth=none)"
  localwd=$(native_path "$TRASHDIR/$reponame")
  localgit=$(native_path "$TRASHDIR/$reponame/.git")
  localgitstore=$(native_path "$TRASHDIR/$reponame/.git")
  localmedia=$(native_path "$TRASHDIR/$reponame/.git/lfs/objects")
  tempdir=$(native_path "$TRASHDIR/$reponame/.git/lfs/tmp")
  envVars=$(printf "%s" "$(env | grep "^GIT")")
  expected=$(printf '%s
%s

Endpoint=%s
Endpoint (other)=%s
LocalWorkingDir=%s
LocalGitDir=%s
LocalGitStorageDir=%s
LocalMediaDir=%s
TempDir=%s
ConcurrentTransfers=3
BatchTransfer=true
%s
%s
' "$(git lfs version)" "$(git version)" "$endpoint" "$endpoint2" "$localwd" "$localgit" "$localgitstore" "$localmedia" "$tempdir" "$envVars" "$envInitConfig")
  actual=$(git lfs env)
  contains_same_elements "$expected" "$actual"

  cd .git
  expected2=$(echo "$expected" | sed -e 's/LocalWorkingDir=.*/LocalWorkingDir=/')
  actual2=$(git lfs env)
  contains_same_elements "$expected2" "$actual2"
)
end_test

begin_test "env with other remote"
(
  set -e
  reponame="env-other-remote"
  mkdir $reponame
  cd $reponame
  git init
  git remote add other "$GITSERVER/env-other-remote"

  endpoint="$GITSERVER/env-other-remote.git/info/lfs (auth=none)"
  localwd=$(native_path "$TRASHDIR/$reponame")
  localgit=$(native_path "$TRASHDIR/$reponame/.git")
  localgitstore=$(native_path "$TRASHDIR/$reponame/.git")
  localmedia=$(native_path "$TRASHDIR/$reponame/.git/lfs/objects")
  tempdir=$(native_path "$TRASHDIR/$reponame/.git/lfs/tmp")
  envVars=$(printf "%s" "$(env | grep "^GIT")")

  expected=$(printf '%s
%s

Endpoint (other)=%s
LocalWorkingDir=%s
LocalGitDir=%s
LocalGitStorageDir=%s
LocalMediaDir=%s
TempDir=%s
ConcurrentTransfers=3
BatchTransfer=true
%s
%s
' "$(git lfs version)" "$(git version)" "$endpoint" "$localwd" "$localgit" "$localgitstore" "$localmedia" "$tempdir" "$envVars" "$envInitConfig")
  actual=$(git lfs env)
  contains_same_elements "$expected" "$actual"

  cd .git
  expected2=$(echo "$expected" | sed -e 's/LocalWorkingDir=.*/LocalWorkingDir=/')
  actual2=$(git lfs env)
  contains_same_elements "$expected2" "$actual2"
)
end_test

begin_test "env with multiple remotes and lfs.url config"
(
  set -e
  reponame="env-multiple-remotes-with-lfs-url"
  mkdir $reponame
  cd $reponame
  git init
  git remote add origin "$GITSERVER/env-origin-remote"
  git remote add other "$GITSERVER/env-other-remote"
  git config lfs.url "http://foo/bar"

  endpoint="$GITSERVER/env-other-remote.git/info/lfs (auth=none)"
  localwd=$(native_path "$TRASHDIR/$reponame")
  localgit=$(native_path "$TRASHDIR/$reponame/.git")
  localgitstore=$(native_path "$TRASHDIR/$reponame/.git")
  localmedia=$(native_path "$TRASHDIR/$reponame/.git/lfs/objects")
  tempdir=$(native_path "$TRASHDIR/$reponame/.git/lfs/tmp")
  envVars=$(printf "%s" "$(env | grep "^GIT")")
  expected=$(printf '%s
%s

Endpoint=http://foo/bar (auth=none)
Endpoint (other)=%s
LocalWorkingDir=%s
LocalGitDir=%s
LocalGitStorageDir=%s
LocalMediaDir=%s
TempDir=%s
ConcurrentTransfers=3
BatchTransfer=true
%s
%s
' "$(git lfs version)" "$(git version)" "$endpoint" "$localwd" "$localgit" "$localgitstore" "$localmedia" "$tempdir" "$envVars" "$envInitConfig")
  actual=$(git lfs env)
  contains_same_elements "$expected" "$actual"

  cd .git
  expected2=$(echo "$expected" | sed -e 's/LocalWorkingDir=.*/LocalWorkingDir=/')
  actual2=$(git lfs env)
  contains_same_elements "$expected2" "$actual2"
)
end_test

begin_test "env with multiple remotes and lfs configs"
(
  set -e
  reponame="env-multiple-remotes-lfs-configs"
  mkdir $reponame
  cd $reponame
  git init
  git remote add origin "$GITSERVER/env-origin-remote"
  git remote add other "$GITSERVER/env-other-remote"
  git config lfs.url "http://foo/bar"
  git config remote.origin.lfsurl "http://custom/origin"
  git config remote.other.lfsurl "http://custom/other"

  localwd=$(native_path "$TRASHDIR/$reponame")
  localgit=$(native_path "$TRASHDIR/$reponame/.git")
  localgitstore=$(native_path "$TRASHDIR/$reponame/.git")
  localmedia=$(native_path "$TRASHDIR/$reponame/.git/lfs/objects")
  tempdir=$(native_path "$TRASHDIR/$reponame/.git/lfs/tmp")
  envVars=$(printf "%s" "$(env | grep "^GIT")")
  expected=$(printf '%s
%s

Endpoint=http://foo/bar (auth=none)
Endpoint (other)=http://custom/other (auth=none)
LocalWorkingDir=%s
LocalGitDir=%s
LocalGitStorageDir=%s
LocalMediaDir=%s
TempDir=%s
ConcurrentTransfers=3
BatchTransfer=true
%s
%s
' "$(git lfs version)" "$(git version)" "$localwd" "$localgit" "$localgitstore" "$localmedia" "$tempdir" "$envVars" "$envInitConfig")
  actual=$(git lfs env)
  contains_same_elements "$expected" "$actual"

  cd .git
  expected2=$(echo "$expected" | sed -e 's/LocalWorkingDir=.*/LocalWorkingDir=/')
  actual2=$(git lfs env)
  contains_same_elements "$expected2" "$actual2"
)
end_test

begin_test "env with multiple remotes and lfs url and batch configs"
(
  set -e
  reponame="env-multiple-remotes-lfs-batch-configs"
  mkdir $reponame
  cd $reponame
  git init
  git remote add origin "$GITSERVER/env-origin-remote"
  git remote add other "$GITSERVER/env-other-remote"
  git config lfs.url "http://foo/bar"
  git config lfs.batch false
  git config lfs.concurrenttransfers 5
  git config remote.origin.lfsurl "http://custom/origin"
  git config remote.other.lfsurl "http://custom/other"

  localwd=$(native_path "$TRASHDIR/$reponame")
  localgit=$(native_path "$TRASHDIR/$reponame/.git")
  localgitstore=$(native_path "$TRASHDIR/$reponame/.git")
  localmedia=$(native_path "$TRASHDIR/$reponame/.git/lfs/objects")
  tempdir=$(native_path "$TRASHDIR/$reponame/.git/lfs/tmp")
  envVars=$(printf "%s" "$(env | grep "^GIT")")
  expected=$(printf '%s
%s

Endpoint=http://foo/bar (auth=none)
Endpoint (other)=http://custom/other (auth=none)
LocalWorkingDir=%s
LocalGitDir=%s
LocalGitStorageDir=%s
LocalMediaDir=%s
TempDir=%s
ConcurrentTransfers=5
BatchTransfer=false
%s
%s
' "$(git lfs version)" "$(git version)" "$localwd" "$localgit" "$localgitstore" "$localmedia" "$tempdir" "$envVars" "$envInitConfig")
  actual=$(git lfs env)
  contains_same_elements "$expected" "$actual"

  cd .git
  expected2=$(echo "$expected" | sed -e 's/LocalWorkingDir=.*/LocalWorkingDir=/')
  actual2=$(git lfs env)
  contains_same_elements "$expected2" "$actual2"
)
end_test

begin_test "env with .gitconfig"
(
  set -e
  reponame="env-with-gitconfig"

  git init $reponame
  cd $reponame

  git remote add origin "$GITSERVER/env-origin-remote"
  echo '[remote "origin"]
	lfsurl = http://foobar:8080/
[lfs]
     batch = false
	concurrenttransfers = 5
' > .gitconfig

  localwd=$(native_path "$TRASHDIR/$reponame")
  localgit=$(native_path "$TRASHDIR/$reponame/.git")
  localgitstore=$(native_path "$TRASHDIR/$reponame/.git")
  localmedia=$(native_path "$TRASHDIR/$reponame/.git/lfs/objects")
  tempdir=$(native_path "$TRASHDIR/$reponame/.git/lfs/tmp")
  envVars=$(printf "%s" "$(env | grep "^GIT")")
  expected=$(printf '%s
%s

Endpoint=http://foobar:8080/ (auth=none)
LocalWorkingDir=%s
LocalGitDir=%s
LocalGitStorageDir=%s
LocalMediaDir=%s
TempDir=%s
ConcurrentTransfers=3
BatchTransfer=true
%s
%s
' "$(git lfs version)" "$(git version)" "$localwd" "$localgit" "$localgitstore" "$localmedia" "$tempdir" "$envVars" "$envInitConfig")
  actual=$(git lfs env)
  contains_same_elements "$expected" "$actual"

  mkdir a
  cd a
  actual2=$(git lfs env)
  contains_same_elements "$expected" "$actual2"
)
end_test

begin_test "env with environment variables"
(
  set -e
  reponame="env-with-envvars"
  git init $reponame
  mkdir -p $reponame/a/b/c

  gitDir=$(native_path "$TRASHDIR/$reponame/.git")
  workTree=$(native_path "$TRASHDIR/$reponame/a/b")

  localwd=$(native_path "$TRASHDIR/$reponame/a/b")
  localgit=$(native_path "$TRASHDIR/$reponame/.git")
  localgitstore=$(native_path "$TRASHDIR/$reponame/.git")
  localmedia=$(native_path "$TRASHDIR/$reponame/.git/lfs/objects")
  tempdir=$(native_path "$TRASHDIR/$reponame/.git/lfs/tmp")
  envVars="$(GIT_DIR=$gitDir GIT_WORK_TREE=$workTree env | grep "^GIT" | sort)"
  expected=$(printf '%s
%s

LocalWorkingDir=%s
LocalGitDir=%s
LocalGitStorageDir=%s
LocalMediaDir=%s
TempDir=%s
ConcurrentTransfers=3
BatchTransfer=true
%s
%s
' "$(git lfs version)" "$(git version)" "$localwd" "$localgit" "$localgitstore" "$localmedia" "$tempdir" "$envVars" "$envInitConfig")

  actual=$(GIT_DIR=$gitDir GIT_WORK_TREE=$workTree git lfs env)
  contains_same_elements "$expected" "$actual"

  cd $TRASHDIR/$reponame
  actual2=$(GIT_DIR=$gitDir GIT_WORK_TREE=$workTree git lfs env)
  contains_same_elements "$expected" "$actual2"

  cd $TRASHDIR/$reponame/.git
  actual3=$(GIT_DIR=$gitDir GIT_WORK_TREE=$workTree git lfs env)
  contains_same_elements "$expected" "$actual3"

  cd $TRASHDIR/$reponame/a/b/c
  actual4=$(GIT_DIR=$gitDir GIT_WORK_TREE=$workTree git lfs env)
  contains_same_elements "$expected" "$actual4"

  envVars="$(GIT_DIR=$gitDir GIT_WORK_TREE=a/b env | grep "^GIT" | sort)"
  expected5=$(printf '%s
%s

LocalWorkingDir=%s
LocalGitDir=%s
LocalGitStorageDir=%s
LocalMediaDir=%s
TempDir=%s
ConcurrentTransfers=3
BatchTransfer=true
%s
git config filter.lfs.smudge = \"\"
git config filter.lfs.clean = \"\"
' "$(git lfs version)" "$(git version)" "$localwd" "$localgit" "$localgitstore" "$localmedia" "$tempdir" "$envVars")
  actual5=$(GIT_DIR=$gitDir GIT_WORK_TREE=a/b git lfs env)
  contains_same_elements "$expected5" "$actual5"

  cd $TRASHDIR/$reponame/a/b
  envVars="$(GIT_DIR=$gitDir env | grep "^GIT" | sort)"
  expected7=$(printf '%s
%s

LocalWorkingDir=%s
LocalGitDir=%s
LocalGitStorageDir=%s
LocalMediaDir=%s
TempDir=%s
ConcurrentTransfers=3
BatchTransfer=true
%s
%s
' "$(git lfs version)" "$(git version)" "$localwd" "$localgit" "$localgitstore" "$localmedia" "$tempdir" "$envVars" "$envInitConfig")
  actual7=$(GIT_DIR=$gitDir git lfs env)
  contains_same_elements "$expected7" "$actual7"

  cd $TRASHDIR/$reponame/a
  envVars="$(GIT_WORK_TREE=$workTree env | grep "^GIT" | sort)"
  expected8=$(printf '%s
%s

LocalWorkingDir=%s
LocalGitDir=%s
LocalGitStorageDir=%s
LocalMediaDir=%s
TempDir=%s
ConcurrentTransfers=3
BatchTransfer=true
%s
%s
' "$(git lfs version)" "$(git version)" "$localwd" "$localgit" "$localgitstore" "$localmedia" "$tempdir" "$envVars" "$envInitConfig")
  actual8=$(GIT_WORK_TREE=$workTree git lfs env)
  contains_same_elements "$expected8" "$actual8"
)
end_test


begin_test "env with bare repo"
(
  set -e
  reponame="env-with-bare-repo"
  git init --bare $reponame
  cd $reponame

  localgit=$(native_path "$TRASHDIR/$reponame")
  localgitstore=$(native_path "$TRASHDIR/$reponame")
  localmedia=$(native_path "$TRASHDIR/$reponame/lfs/objects")
  tempdir=$(native_path "$TRASHDIR/$reponame/lfs/tmp")
  envVars=$(printf "%s" "$(env | grep "^GIT")")

  expected=$(printf "%s\n%s\n
LocalWorkingDir=
LocalGitDir=%s
LocalGitStorageDir=%s
LocalMediaDir=%s
TempDir=%s
ConcurrentTransfers=3
BatchTransfer=true
%s
%s
" "$(git lfs version)" "$(git version)" "$localgit" "$localgitstore" "$localmedia" "$tempdir" "$envVars" "$envInitConfig")
  actual=$(git lfs env)
  contains_same_elements "$expected" "$actual"

)
end_test
