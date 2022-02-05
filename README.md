1.
commit aefead2207ef7e2aa5dc81a34aedf0cad4c32545

   Update CHANGELOG.md

$ git show aefea


2.
 tag: v0.12.23

$ git show 85024d3



3.
2, 56cd7859e 9ea88f22f

$ git show b8d720



4. 
b14b74c49 [Website] vmc provider links
3f235065b Update CHANGELOG.md
6ae64e247 registry: Fix panic when server is unreachable
5c619ca1b website: Remove links to the getting started guide's old location
06275647e Update CHANGELOG.md
d5f9411f5 command: Fix bug when using terraform login on Windows
4b6d06cc5 Update CHANGELOG.md
dd01a3507 Update CHANGELOG.md
225466bc3 Cleanup after v0.12.23 release

$ git log v0.12.24...v0.12.23 --oneline


5.  
8c928e83589d90a031f811fae52a81be7153e82f

$ git log -S'func providerSource('


6. 
78b12205587fe839f10d946ea3fdc06719decb05
52dbf94834cb970b510f2fba853a5b49ad9b1a46
41ab0aef7a0fe030e84018973a64135b11abcd70
66ebff90cdfaa6938f26f908c7ebad8d547fea17
8364383c359a6b738a436d1b7745ccdce178df47


$ git grep -p 'globalPluginDirs('
$ git log -L :globalPluginDirs:plugins.go

7. 
Martin Atkins <mart@degeneration.co.uk>

$ git log -SsynchronizedWriters
$ git show 5ac311e2a91e381e2f52234668b49ba670aa0fe5 | grep 'func synchronizedWriters'

 
