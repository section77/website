# Section77 website

This repo contains the source of our website at: https://section77.de.


## Page deployment

We use [Lektor](https://www.getlektor.com/) to build our static site.

The site will be build from this [GitHub action](https://github.com/section77/website/blob/master/.github/workflows/gh-pages.yml)

  - on every push on the master branch
  - at 02:30 UTC every day (to remove past events from the calendar on the main page)


## Event scheduling

[chaostreff-scheduler](https://github.com/section77/chaostreff-scheduler) is our event scheduler.

This [GitHub action](https://github.com/section77/website/blob/master/.github/workflows/schedule.yml) triggers the scheduling

  - at 02:01 UTC on the 1st of every month
  - when someone pushes changes to 'templates/chaostreff-scheduler/'

### How-to

#### Change the text for the generated events

You can find the templates for the events under [templates/chaostreff-scheduler](https://github.com/section77/website/tree/master/templates/chaostreff-scheduler).
If the events are already scheduled, you need to remove the generated files under [content/kalender/...'](https://github.com/section77/website/tree/master/content/kalender).

The scheduler doesn't override existing events.

Then you can push your changes, and the GitHub action will run the scheduler.


#### Unschedule an event

If you remove a event, `chaostreff-scheduler` will reschedule the event. You can rename the event
from `contents.lr` to `contents.lr.ignore` to prevent this.


#### Trigger the GitHub action to generate the events

You can change [this file](https://github.com/section77/website/blob/master/templates/chaostreff-scheduler/trigger-scheduler.txt) and
push your changes. This triggers the GitHub action.

## Update chaostreff-scheduler
When the [chaostreff-scheduler](https://github.com/section77/chaostreff-scheduler) is changed, default.nix must be updated with the current commit hash and the nix hash need to be set to "". Then nix will complain and generate the actual [nix hash](https://nixos.wiki/wiki/Nix_Hash) (to be looked up in the ci job). This hash then needs to be inserted in the default.nix file.

## Update nixos
From time to time or if HTTP Status 404, the nixos channel must be updated in the [workflows](.github/workflows/) and in the [default.nix](default.nix) file.
You'll get the current one at [Nix Channel Status](https://status.nixos.org).
