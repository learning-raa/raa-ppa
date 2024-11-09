GPG_ID=alexander@mail.com
TRUSTED_PPA_GPG_NAME=learning_raa_ppa.gpg
PPA_URL=https://learning-raa.github.io/raa-ppa
LIST_FILE=debraa.list


help:
	@nvim Makefile

update.short: update.packages update.in_release
	@echo 'SHORT update done!'

update.all: update.key.gpg update.packages update.in_release update.list_file
	@echo 'FULL update done!'

update.list_file:
	@echo "updating list file.."
	@echo "deb $(PPA_URL) ./" > $(LIST_FILE)
	# @echo "deb [signed-by=/etc/apt/trusted.gpg.g/$(TRUSTED_PPA_GPG_NAME)] $(PPA_URL) ./" \
	#	> $(LIST_FILE)

update.in_release:
	@echo "updating InRelease .."
	@apt-ftparchive release . > Release
	@gpg --default-key $(GPG_ID) -abs -o - Release > Release.gpg
	@gpg --default-key $(GPG_ID) --clearsign -o - Release > InRelease

update.packages:
	@echo "updating Packages .."
	@dpkg-scanpackages --multiversion . > Packages
	@gzip -k -f Packages

update.key.gpg:
	@echo "updating KEY.gpg .."
	@gpg --armor --export $(GPG_ID) > KEY.gpg

clear:
	@rm -v KEY.gpg Packages Packages.gz Release Release.gpg InRelease $(LIST_FILE)

# # # # # # # #
install:
	@curl -s --compressed "$(PPA_URL)/KEY.gpg" | gpg --dearmor \
		| sudo tee "/etc/apt/trusted.gpg.d/$(TRUSTED_PPA_GPG_NAME)" \
		> /dev/null
	@sudo curl -s --compressed \
		-o "/etc/apt/sources.list.d/$(LIST_FILE)" \
		"$(PPA_URL)/$(LIST_FILE)"

# # # # # # # #
pull:
	@git pull

savetogit: git.pushall
git.pushall: git.commitall
	@git push
git.commitall: git.addall
	@if [ -n "$(shell git status -s)" ] ; then \
		git commit -m 'saving'; \
		else echo '--- nothing to commit'; \
		fi
git.addall:
	@git add .
