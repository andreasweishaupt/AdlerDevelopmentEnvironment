## Debug shell scripts manually executed in WSL
For PHPStorm path mapping to work it is required to set an environment variable in the WSL instance before executing the PHP script: `export PHP_IDE_CONFIG="serverName=localhost"` \
"localhost" is the name of the server configured in PHPStorm.

It might be necessary to manually set the idekey: `export XDEBUG_CONFIG="idekey=blub"`. The value itself ("blub") is irrelevant.
