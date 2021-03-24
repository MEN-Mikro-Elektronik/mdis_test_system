# Creating packages

After the functional tests have been performed it is necessary to create beta release package for acceptance tests and finally the release package.

There is deliberately no script for creating packages to avoid mistakes and the process should be understood, however some example commands have been provided.

## Beta package

The beta package serves the acceptance tests. It should be as close as possible the release package.

- All submodules should be merged from their corresponding development branch to master branch
- For all submodules the last tag should reference the last commit (if not, a tag should be created and tag version increased)
- A new branch for the main repository should be created (release-13MD05_xx_xx_b1) and should contain all the development branch changes, except it should reference the submodules from master branches
- A new branch should be taged (if not, a tag should be created and tag version increased)
- Package should contain HISTORY directory for offline installation
- Package should not contain any version control system files (git)
- Package should be compressed and named release-13MD05_xx_xx_b1.tar.gz


1. It's best to start with fresh master branch downloaded

$ git clone --recurse-submodules -b master https://github.com/MEN-Mikro-Elektronik/13MD05-90 release-13MD05-90_02\_*04*\_b1

2. Almos everything will happen in this directory

$ cd release-13MD05-90_02\_*04*\_b1

3. Create new beta release branch

$ git checkout -b release-13MD05-90_02\_*04*\_b1

4. Merge development branch into new beta release branch

$ git merge origin/*jpe-dev*

5. Each submodule in beta release branch should reference master branch

$ git submodule foreach 'cd -; git submodule set-branch -d ${sm_path}; cd -'

6. Sometimes the above doesn't work for all submodules

$ sed -i '/branch[[:space:]]*=/d' .gitmodules

7. Each submodule should reference master branch

$ git submodule foreach git checkout master

8. Each submodule should be merged with development branch

$ git submodule foreach git merge origin/*jpe-dev*

9. Each submodule commits are pushed to remote

$git submodule foreach git push

10. Check which submodule needs a new tag

$ git submodule --quiet foreach 'if [ "$(git rev-list --tags --max-count=1)" != "$(git rev-parse HEAD)" ]; then echo "new tag is needed for ${sm_path}"; fi' 

11. Create tag for each submodule that needs it

1. Go to the sumbodule directory

$ cd *13Z025-90*

2. Get the last tag name

$ git describe --tags "$(git rev-list --tags --max-count=1)"

3. Create tag with an updated name

$ git tag -a *13Z025-90_01_19* -m "Tag created for MDIS release 13MD05-90_02_*04*"

4. Push tag to remote

$ git push --tags

5. Go back to previous directory

$ cd -

12. Add all changes

$ git add -u

13. Commit all changes

$ git commit -m "Switch submodules to master branch"

14. Push commit to remote

$ git push --set-upstream origin release-13MD05-90_02\_*04*\_b1

15. Create tag with an updated name

$ git tag -a 13MD05-90_02\_*04*\_b1 -m "Beta 1 version for 13MD05-90_02\_*04*"

16. Push tag to remote

$ git push --tags

17. Go to the directory below

$ cd ..

18. Download new beta release

$ git clone --recurse-submodules -b release-13MD05-90_02\_*04*\_b1 https://github.com/MEN-Mikro-Elektronik/13MD05-90 13MD05-90

19. Go to beta release directory

$ cd 13MD05-90

20. Create HISTORY directory with content

$ ./INSTALL.sh --install-only

21. Remove all git related files

$ find . -name '.git*' -exec rm -rf '{}' \;

22. Go to the previous direcory

$ cd -

23. Create tar.gz archive

$ tar -czf 13MD05-90_02\_*04*\_b1.tar.gz 13MD05-90

## Release package
