Generate a list of repositories from an existing file hierarchy:

bash gitlist.sh <path>


--

Clone all repositories in a newline separated file of urls

cat <file> | bash gitstart.sh


--

remote update (fetch) all repos in file hierarchy

bash gitrefresh.sh update <path>

remote update and pull (current branch) all repos in file hierachy

bash gitrefresh.sh pull <path>

--

CAVEATS:

- Remote name is hardcoded to "origin."

- May give strange results on repositories that are in detached head state
