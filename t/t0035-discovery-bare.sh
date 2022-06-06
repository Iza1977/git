#!/bin/sh

test_description='verify discovery.bare checks'

. ./test-lib.sh

pwd="$(pwd)"

expect_allowed () {
	git rev-parse --absolute-git-dir >actual &&
	echo "$pwd/outer-repo/bare-repo" >expected &&
	test_cmp expected actual
}

expect_rejected () {
	test_must_fail git rev-parse --absolute-git-dir 2>err &&
	grep "discovery.bare" err
}

test_expect_success 'setup bare repo in worktree' '
	git init outer-repo &&
	git init --bare outer-repo/bare-repo
'

test_expect_success 'discovery.bare unset' '
	(
		cd outer-repo/bare-repo &&
		expect_allowed &&
		cd refs/ &&
		expect_allowed
	)
'

test_expect_success 'discovery.bare=always' '
	git config --global discovery.bare always &&
	(
		cd outer-repo/bare-repo &&
		expect_allowed &&
		cd refs/ &&
		expect_allowed
	)
'

test_expect_success 'discovery.bare=never' '
	git config --global discovery.bare never &&
	(
		cd outer-repo/bare-repo &&
		expect_rejected &&
		cd refs/ &&
		expect_rejected
	) &&
	(
		GIT_DIR=outer-repo/bare-repo &&
		export GIT_DIR &&
		expect_allowed
	)
'

test_expect_success 'discovery.bare=cwd' '
	git config --global discovery.bare cwd &&
	(
		cd outer-repo/bare-repo &&
		expect_allowed &&
		cd refs/ &&
		expect_rejected
	)
'

test_done
