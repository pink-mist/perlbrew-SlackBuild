
sbos := perl-CPAN-Perl-Releases perl-File-pushd perl-Devel-PatchPerl perl-Test-Output perl-Test-Spec perl-local-lib perlbrew
tars := $(sbos:%=tars/%.tar)
infos := $(foreach sbo,$(sbos),$(subst LL,$(sbo),src/LL/LL.info))

tar : $(tars)

$(infos) : urls
	@./update.pl $@

define sbo_template =
${1} : src/${1}/${1}.info src/${1}/${1}.SlackBuild src/${1}/README src/${1}/slack-desc
	@rm -rf ${1}
	cp -r src/${1} ${1}
endef

$(foreach sbo,$(sbos),$(eval $(call sbo_template,${sbo})))

$(tars) : tars/%.tar: %
	tar cvf $@ $<

.PHONY : clean

clean :
	-rm -f $(tars) 2>/dev/null
	-rm -rf $(sbos) 2>/dev/null
