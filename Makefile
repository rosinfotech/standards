# --- vendored makefile framework (make vendor) ---
# --- vendored makefile framework (make vendor) ---
# Standalone definitions: this Makefile does not require the globally
# linked make (update: make vendor <this path>; remove: delete this block
# and .makefile/vendor/rosinfotech/).
# Command input: make <command> ["<one positional>"] [args="<flags>"] - the
# single input channel; environment variables are not a command interface.

define resolve_script
$(if $(wildcard $(CURDIR)/.makefile/$(1)),$(CURDIR)/.makefile/$(1),$(CURDIR)/.makefile/vendor/rosinfotech/$(1))
endef

.DEFAULT_GOAL := echo
.PHONY: echo init clear kill_processes setup version_show version_update git_flow_clear git_flow_commit git_flow_commit_push git_flow_help git_flow_init git_flow_promote git_flow_status git_flow_seal git_flow_hotfix_finish git_flow_hotfix_start git_flow_task_finish git_flow_task_fragment git_flow_task_merge_develop git_flow_task_start
.SILENT: echo init clear kill_processes setup version_show version_update git_flow_clear git_flow_commit git_flow_commit_push git_flow_help git_flow_init git_flow_promote git_flow_status git_flow_seal git_flow_hotfix_finish git_flow_hotfix_start git_flow_task_finish git_flow_task_fragment git_flow_task_merge_develop git_flow_task_start

init:
	chmod +x $(wildcard $(CURDIR)/.makefile/*.sh) $(wildcard $(CURDIR)/.makefile/vendor/rosinfotech/*.sh)

echo: init
	GLOBAL_ROOT="$(CURDIR)/.makefile/vendor/rosinfotech" $(call resolve_script,echo.sh)

clear: init
	$(call resolve_script,clear.sh)

kill_processes: init
	$(call resolve_script,kill_processes.sh)

setup: init
	$(call resolve_script,setup.sh)

version_show: init
	$(call resolve_script,version_show.sh)

version_update: init
	$(call resolve_script,version_update.sh)

git_flow_clear: init
	$(call resolve_script,git_flow_clear.sh) $(args)

git_flow_commit: init
	$(call resolve_script,git_flow_commit.sh) "$(filter-out $@,$(MAKECMDGOALS))" $(args)

git_flow_commit_push: init
	$(call resolve_script,git_flow_commit_push.sh) "$(filter-out $@,$(MAKECMDGOALS))" $(args)

git_flow_help: init
	$(call resolve_script,git_flow_help.sh)

git_flow_init: init
	$(call resolve_script,git_flow_init.sh) "$(filter-out $@,$(MAKECMDGOALS))" $(args)

git_flow_promote: init
	$(call resolve_script,git_flow_promote.sh) $(args)

git_flow_status: init
	$(call resolve_script,git_flow_status.sh)

git_flow_seal: init
	$(call resolve_script,git_flow_seal.sh) "$(filter-out $@,$(MAKECMDGOALS))" $(args)

git_flow_hotfix_finish: init
	$(call resolve_script,git_flow_hotfix_finish.sh) $(args)

git_flow_hotfix_start: init
	$(call resolve_script,git_flow_hotfix_start.sh) "$(filter-out $@,$(MAKECMDGOALS))" $(args)

git_flow_task_finish: init
	$(call resolve_script,git_flow_task_finish.sh) $(args)

git_flow_task_fragment: init
	$(call resolve_script,git_flow_task_fragment.sh) "$(filter-out $@,$(MAKECMDGOALS))" $(args)

git_flow_task_merge_develop: init
	$(call resolve_script,git_flow_task_merge_develop.sh) $(args)

git_flow_task_start: init
	$(call resolve_script,git_flow_task_start.sh) "$(filter-out $@,$(MAKECMDGOALS))" $(args)

%:
	@:

# --- end vendored makefile framework ---

