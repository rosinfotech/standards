# --- vendored makefile framework (make vendor) ---
# --- vendored makefile framework (make vendor) ---
# Standalone definitions: this Makefile does not require the globally
# linked make (update: make vendor <this path>; remove: delete this block
# and .makefile/vendor/rosinfotech/).

define resolve_script
$(if $(wildcard $(CURDIR)/.makefile/$(1)),$(CURDIR)/.makefile/$(1),$(CURDIR)/.makefile/vendor/rosinfotech/$(1))
endef

export FLOW_RELEASE FLOW_YES

.DEFAULT_GOAL := echo
.PHONY: echo init clear git_flow_commit git_flow_commit_push git_flow_commit_version git_flow_prepare_release git_flow_init git_flow_status git_flow_stamp git_flow_hotfix_finish git_flow_hotfix_start git_flow_task_finish git_flow_task_fragment git_flow_task_dev_merge git_flow_task_start kill_processes setup version_show version_update
.SILENT: echo init clear git_flow_commit git_flow_commit_push git_flow_commit_version git_flow_prepare_release git_flow_init git_flow_status git_flow_stamp git_flow_hotfix_finish git_flow_hotfix_start git_flow_task_finish git_flow_task_fragment git_flow_task_dev_merge git_flow_task_start kill_processes setup version_show version_update

init:
	chmod +x $(wildcard $(CURDIR)/.makefile/*.sh) $(wildcard $(CURDIR)/.makefile/vendor/rosinfotech/*.sh)

echo: init
	GLOBAL_ROOT="$(CURDIR)/.makefile/vendor/rosinfotech" $(call resolve_script,echo.sh)

clear: init
	$(call resolve_script,clear.sh)

git_flow_commit: init
	$(call resolve_script,git_flow_commit.sh) "$(filter-out $@,$(MAKECMDGOALS))"

git_flow_commit_push: init
	$(call resolve_script,git_flow_commit_push.sh) "$(filter-out $@,$(MAKECMDGOALS))"

git_flow_commit_version: init
	$(call resolve_script,git_flow_commit_version.sh) "$(filter-out $@,$(MAKECMDGOALS))"

git_flow_prepare_release: init
	$(call resolve_script,git_flow_prepare_release.sh)

git_flow_init: init
	$(call resolve_script,git_flow_init.sh) "$(filter-out $@,$(MAKECMDGOALS))"

git_flow_status: init
	$(call resolve_script,git_flow_status.sh)

git_flow_stamp: init
	$(call resolve_script,git_flow_stamp.sh)

git_flow_hotfix_finish: init
	$(call resolve_script,git_flow_hotfix_finish.sh)

git_flow_hotfix_start: init
	$(call resolve_script,git_flow_hotfix_start.sh) "$(filter-out $@,$(MAKECMDGOALS))"

git_flow_task_finish: init
	$(call resolve_script,git_flow_task_finish.sh)

git_flow_task_fragment: init
	$(call resolve_script,git_flow_task_fragment.sh) "$(filter-out $@,$(MAKECMDGOALS))"

git_flow_task_dev_merge: init
	$(call resolve_script,git_flow_task_dev_merge.sh)

git_flow_task_start: init
	$(call resolve_script,git_flow_task_start.sh) "$(filter-out $@,$(MAKECMDGOALS))"

kill_processes: init
	$(call resolve_script,kill_processes.sh)

setup: init
	$(call resolve_script,setup.sh)

version_show: init
	$(call resolve_script,version_show.sh)

version_update: init
	$(call resolve_script,version_update.sh)

%:
	@:

# --- end vendored makefile framework ---

