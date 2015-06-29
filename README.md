## Kickstarter-To-Slack

A simple script to periodically check a Kickstarter project for funding updates and post to Slack if something has changed.

Configure it by using `direnv`.

## Example

    export SLACK_HOOK_CREDENTIALS='XXXXXXXXX/XXXXXXXXX/XXXXXXXXXXXXXXXXXXXXXXXX'
    export KICKSTARTER_PASSWORD='really_good_password'
    export KICKSTARTER_EMAIL='ian@example.com'
    export KICKSTARTER_PROJECT_SLUG='the-awesome-project'
    export SLACK_CHANNELS='#general #kickstarter'
