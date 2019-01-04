php -r "readfile('http://files.drush.org/drush.phar');" > drush
# Or use our upcoming release: php -r "readfile('http://files.drush.org/drush-unstable.phar');" > drush

# Test your install.
php drush core-status

# Make `drush` executable as a command from anywhere. Destination can be anywhere on $PATH.
chmod +x drush
mv drush /usr/local/bin

# Optional. Enrich the bash startup file with completion and aliases.
drush init
